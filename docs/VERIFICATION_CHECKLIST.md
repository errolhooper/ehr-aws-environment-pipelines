# Manual Verification Checklist

Use this checklist to verify the Terraform backend infrastructure after bootstrapping.

## Pre-Bootstrap Verification

- [ ] Terraform installed (>= 1.0)
- [ ] AWS CLI configured with valid credentials
- [ ] AWS account IDs updated in all `terraform.tfvars.*` files
- [ ] Correct permissions to create S3, DynamoDB, and KMS resources

## Bootstrap Process Verification

### For Each Environment (dev, qa, prod, courses):

- [ ] Navigate to `infra/bootstrap/`
- [ ] Run `terraform init` successfully
- [ ] Run `terraform plan -var-file=terraform.tfvars.{env}`
- [ ] Review plan output for expected resources:
  - 1 S3 bucket
  - 1 DynamoDB table
  - 1 KMS key (if create_kms_key = true)
  - 1 KMS alias (if create_kms_key = true)
- [ ] Run `terraform apply -var-file=terraform.tfvars.{env}`
- [ ] Note the outputs (bucket ARN, table ARN, KMS key ARN)

## AWS Console Verification

### S3 Buckets

For each environment, verify in AWS Console:

#### Development (`tfstate-dev-us-east-1`)
- [ ] Bucket exists
- [ ] Versioning: Enabled
- [ ] Encryption: AES-256 or KMS
- [ ] Public access: All blocked
- [ ] Lifecycle rules: 2 rules configured
  - [ ] Rule 1: Expire noncurrent versions after 90 days
  - [ ] Rule 2: Abort incomplete uploads after 7 days
- [ ] Tags present: Name, Purpose, Environment

#### QA (`tfstate-qa-us-east-1`)
- [ ] Bucket exists
- [ ] Versioning: Enabled
- [ ] Encryption: AES-256 or KMS
- [ ] Public access: All blocked
- [ ] Lifecycle rules: 2 rules configured
- [ ] Tags present

#### Production (`tfstate-prod-us-east-1`)
- [ ] Bucket exists
- [ ] Versioning: Enabled
- [ ] Encryption: AES-256 or KMS
- [ ] Public access: All blocked
- [ ] Lifecycle rules: 2 rules configured
- [ ] Tags present

#### Courses (`tfstate-courses-us-east-1`)
- [ ] Bucket exists
- [ ] Versioning: Enabled
- [ ] Encryption: AES-256 or KMS
- [ ] Public access: All blocked
- [ ] Lifecycle rules: 2 rules configured
- [ ] Tags present

### DynamoDB Tables

For each environment, verify in AWS Console:

#### Development (`tf-locks-dev`)
- [ ] Table exists
- [ ] Billing mode: PAY_PER_REQUEST
- [ ] Partition key: LockID (String)
- [ ] Encryption: Enabled (AWS owned key or KMS)
- [ ] Point-in-time recovery: Enabled
- [ ] Tags present: Name, Purpose, Environment

#### QA (`tf-locks-qa`)
- [ ] Table exists
- [ ] Configuration matches dev

#### Production (`tf-locks-prod`)
- [ ] Table exists
- [ ] Configuration matches dev

#### Courses (`tf-locks-courses`)
- [ ] Table exists
- [ ] Configuration matches dev

### KMS Keys (if created)

For each environment, verify in AWS Console:

#### Development (`alias/terraform-state-dev`)
- [ ] Key exists
- [ ] Key rotation: Enabled
- [ ] Alias: `alias/terraform-state-dev`
- [ ] Description mentions environment
- [ ] Tags present

#### QA, Production, Courses
- [ ] Keys exist with appropriate aliases
- [ ] Key rotation enabled on all

## CLI Verification

### S3 Buckets
```bash
# List all tfstate buckets
aws s3 ls | grep tfstate

# Check versioning on dev bucket
aws s3api get-bucket-versioning --bucket tfstate-dev-us-east-1

# Check encryption on dev bucket
aws s3api get-bucket-encryption --bucket tfstate-dev-us-east-1

# Check public access block
aws s3api get-public-access-block --bucket tfstate-dev-us-east-1

# Check lifecycle configuration
aws s3api get-bucket-lifecycle-configuration --bucket tfstate-dev-us-east-1
```

### DynamoDB Tables
```bash
# List tables
aws dynamodb list-tables | grep tf-locks

# Describe dev table
aws dynamodb describe-table --table-name tf-locks-dev

# Check point-in-time recovery
aws dynamodb describe-continuous-backups --table-name tf-locks-dev
```

### KMS Keys
```bash
# List KMS aliases
aws kms list-aliases | grep terraform-state

# Describe key rotation
aws kms get-key-rotation-status --key-id alias/terraform-state-dev
```

## Environment Backend Verification

For each environment (dev, qa, prod, courses):

### Development
```bash
cd infra/live/dev

# Initialize with backend
terraform init

# Should see message about configuring S3 backend
# No errors should occur

# List state (should show remote backend)
terraform state list

# If empty, that's OK (no resources yet)
```

- [ ] `terraform init` succeeds
- [ ] Backend configured successfully
- [ ] No initialization errors
- [ ] State stored in S3 (check output)

### QA
```bash
cd infra/live/qa
terraform init
terraform state list
```
- [ ] Backend initialization successful

### Production
```bash
cd infra/live/prod
terraform init
terraform state list
```
- [ ] Backend initialization successful

### Courses
```bash
cd infra/live/courses
terraform init
terraform state list
```
- [ ] Backend initialization successful

## State Locking Verification

Test that state locking works:

### Terminal 1:
```bash
cd infra/live/dev
terraform plan
# Keep this running
```

### Terminal 2:
```bash
cd infra/live/dev
terraform plan
```

- [ ] Second terminal shows lock error
- [ ] Lock error message includes DynamoDB table name
- [ ] Lock ID is displayed
- [ ] After first terminal completes, second command can proceed

## Security Verification

### Public Access
```bash
# Attempt to access bucket publicly (should fail)
curl -I https://tfstate-dev-us-east-1.s3.amazonaws.com
```
- [ ] Returns 403 Forbidden or similar error

### IAM Permissions
- [ ] Review IAM policies follow least privilege
- [ ] Only authorized users/roles can access state buckets
- [ ] Only authorized users/roles can access DynamoDB tables

### Encryption Verification
```bash
# Upload a test file and verify encryption
echo "test" > /tmp/test.txt
aws s3 cp /tmp/test.txt s3://tfstate-dev-us-east-1/test.txt
aws s3api head-object --bucket tfstate-dev-us-east-1 --key test.txt
```
- [ ] ServerSideEncryption is set (AES256 or aws:kms)
- [ ] Clean up test file: `aws s3 rm s3://tfstate-dev-us-east-1/test.txt`

## Documentation Verification

- [ ] README.md is updated with setup instructions
- [ ] docs/terraform-backend.md contains complete documentation
- [ ] docs/QUICK_START.md provides quick start guide
- [ ] infra/bootstrap/README.md explains bootstrap process
- [ ] All ARN placeholders updated with actual values (after bootstrap)

## Final Checks

- [ ] All Terraform configurations formatted: `terraform fmt -recursive`
- [ ] All configurations validated successfully
- [ ] .gitignore properly excludes sensitive files
- [ ] Lock files (.terraform.lock.hcl) committed
- [ ] Example tfvars files committed
- [ ] No secrets or sensitive data in version control
- [ ] Bootstrap state files backed up securely

## Post-Deployment Updates

After bootstrap completion:

- [ ] Update `docs/terraform-backend.md` with actual ARNs
- [ ] Update environment `backend.tf` files with KMS key IDs (if using KMS)
- [ ] Document any custom configurations or deviations
- [ ] Share bucket names and table names with team
- [ ] Configure IAM policies for team access
- [ ] Set up CloudTrail logging for audit trail (optional)
- [ ] Configure backup strategy for bootstrap state files

## Troubleshooting Checklist

If issues arise:

- [ ] Check Terraform version: `terraform version`
- [ ] Check AWS CLI configuration: `aws sts get-caller-identity`
- [ ] Enable debug logging: `export TF_LOG=DEBUG`
- [ ] Review Terraform error messages carefully
- [ ] Check AWS CloudTrail for API errors
- [ ] Verify bucket names are globally unique
- [ ] Ensure sufficient AWS service quotas
- [ ] Check for naming conflicts with existing resources

## Success Criteria

All the following must be true:

✅ Backend infrastructure created for all 4 environments
✅ All security controls validated (encryption, public access blocking, versioning)
✅ `terraform init` works in all environment directories
✅ State locking tested and working
✅ Documentation complete and accurate
✅ No secrets in version control
✅ Team members can access and use the infrastructure

---

**Sign-off:**

- [ ] All checklist items completed
- [ ] Ready for team use
- [ ] Documentation reviewed
- [ ] Issue can be closed

**Verified by:** _______________
**Date:** _______________
**Notes:**
