# Terraform Backend Configuration

This document describes the Terraform backend infrastructure for managing state and locking across all environments in the EHR AWS Environment Pipelines project.

## Overview

The Terraform backend infrastructure consists of:
- **S3 buckets** for state storage with versioning and encryption
- **DynamoDB tables** for state locking to prevent concurrent modifications
- **KMS keys** (optional) for enhanced encryption security

## Architecture

### State Storage
Each environment has its own dedicated S3 bucket to isolate state files and prevent cross-environment contamination.

### State Locking
DynamoDB tables provide distributed locking to ensure only one operation can modify state at a time, preventing corruption.

### Security Controls
- **Encryption at Rest**: AES-256 or KMS encryption on S3 buckets
- **Encryption in Transit**: SSL/TLS enforced for all S3 operations
- **Public Access Blocking**: All public access blocked on state buckets
- **Versioning**: Enabled to track state changes and enable rollback
- **DynamoDB Encryption**: Server-side encryption enabled by default

## Environments

### Development Environment

**S3 Bucket:**
- Name: `tfstate-dev-us-east-1`
- ARN: `arn:aws:s3:::tfstate-dev-us-east-1`
- Region: `us-east-1`
- Encryption: KMS (with key rotation enabled)
- Versioning: Enabled
- Lifecycle: Noncurrent versions expire after 90 days

**DynamoDB Table:**
- Name: `tf-locks-dev`
- ARN: `arn:aws:dynamodb:us-east-1:ACCOUNT_ID:table/tf-locks-dev`
- Billing Mode: PAY_PER_REQUEST
- Encryption: Server-side encryption enabled
- Point-in-time Recovery: Enabled

**KMS Key:**
- Alias: `alias/terraform-state-dev`
- ARN: `arn:aws:kms:us-east-1:ACCOUNT_ID:key/KEY_ID`

---

### QA Environment

**S3 Bucket:**
- Name: `tfstate-qa-us-east-1`
- ARN: `arn:aws:s3:::tfstate-qa-us-east-1`
- Region: `us-east-1`
- Encryption: KMS (with key rotation enabled)
- Versioning: Enabled
- Lifecycle: Noncurrent versions expire after 90 days

**DynamoDB Table:**
- Name: `tf-locks-qa`
- ARN: `arn:aws:dynamodb:us-east-1:ACCOUNT_ID:table/tf-locks-qa`
- Billing Mode: PAY_PER_REQUEST
- Encryption: Server-side encryption enabled
- Point-in-time Recovery: Enabled

**KMS Key:**
- Alias: `alias/terraform-state-qa`
- ARN: `arn:aws:kms:us-east-1:ACCOUNT_ID:key/KEY_ID`

---

### Production Environment

**S3 Bucket:**
- Name: `tfstate-prod-us-east-1`
- ARN: `arn:aws:s3:::tfstate-prod-us-east-1`
- Region: `us-east-1`
- Encryption: KMS (with key rotation enabled)
- Versioning: Enabled
- Lifecycle: Noncurrent versions expire after 90 days

**DynamoDB Table:**
- Name: `tf-locks-prod`
- ARN: `arn:aws:dynamodb:us-east-1:ACCOUNT_ID:table/tf-locks-prod`
- Billing Mode: PAY_PER_REQUEST
- Encryption: Server-side encryption enabled
- Point-in-time Recovery: Enabled

**KMS Key:**
- Alias: `alias/terraform-state-prod`
- ARN: `arn:aws:kms:us-east-1:ACCOUNT_ID:key/KEY_ID`

---

### Courses Environment

**S3 Bucket:**
- Name: `tfstate-courses-us-east-1`
- ARN: `arn:aws:s3:::tfstate-courses-us-east-1`
- Region: `us-east-1`
- Encryption: KMS (with key rotation enabled)
- Versioning: Enabled
- Lifecycle: Noncurrent versions expire after 90 days

**DynamoDB Table:**
- Name: `tf-locks-courses`
- ARN: `arn:aws:dynamodb:us-east-1:ACCOUNT_ID:table/tf-locks-courses`
- Billing Mode: PAY_PER_REQUEST
- Encryption: Server-side encryption enabled
- Point-in-time Recovery: Enabled

**KMS Key:**
- Alias: `alias/terraform-state-courses`
- ARN: `arn:aws:kms:us-east-1:ACCOUNT_ID:key/KEY_ID`

---

## Bootstrap Process

### Prerequisites
1. AWS CLI configured with appropriate credentials
2. Terraform >= 1.0 installed
3. AWS account IDs for each environment

### Initial Setup

The bootstrap process creates the backend infrastructure for each environment. This must be done **once** before using the backend in each environment.

#### Step 1: Update Account IDs
Edit the environment-specific tfvars file in `infra/bootstrap/`:
```bash
# For development environment
vim infra/bootstrap/terraform.tfvars.dev
```

Replace `REPLACE_WITH_DEV_ACCOUNT_ID` with your actual AWS account ID.

#### Step 2: Initialize Bootstrap Terraform
```bash
cd infra/bootstrap
terraform init
```

#### Step 3: Create Backend Infrastructure

**For Development:**
```bash
terraform apply -var-file=terraform.tfvars.dev
```

**For QA:**
```bash
terraform apply -var-file=terraform.tfvars.qa
```

**For Production:**
```bash
terraform apply -var-file=terraform.tfvars.prod
```

**For Courses:**
```bash
terraform apply -var-file=terraform.tfvars.courses
```

#### Step 4: Note the Outputs
After applying, note the outputs:
- Bucket ARN
- DynamoDB table ARN
- KMS key ARN (if created)

Update this documentation with the actual ARNs.

#### Step 5: Update Backend Configurations (Optional)
If using KMS encryption, uncomment and update the `kms_key_id` line in each environment's `backend.tf` file.

### Using the Backend

Once the backend infrastructure is created, you can initialize Terraform in each environment:

```bash
# Navigate to the environment directory
cd infra/live/dev

# Initialize Terraform with the S3 backend
terraform init

# Verify the backend configuration
terraform state list
```

## Operations

### Accessing State

To view the current state:
```bash
cd infra/live/<environment>
terraform state list
terraform state show <resource>
```

### State Recovery

If state becomes corrupted, you can restore from a previous version:

1. List available versions in S3:
```bash
aws s3api list-object-versions \
  --bucket tfstate-<env>-us-east-1 \
  --prefix <env>/terraform.tfstate
```

2. Download a specific version:
```bash
aws s3api get-object \
  --bucket tfstate-<env>-us-east-1 \
  --key <env>/terraform.tfstate \
  --version-id <version-id> \
  terraform.tfstate.backup
```

3. Replace the current state (use with extreme caution):
```bash
terraform state push terraform.tfstate.backup
```

### Lock Management

If a lock is stuck (e.g., from a crashed Terraform process):

1. Identify the lock:
```bash
aws dynamodb scan \
  --table-name tf-locks-<env> \
  --region us-east-1
```

2. Delete the stuck lock:
```bash
aws dynamodb delete-item \
  --table-name tf-locks-<env> \
  --key '{"LockID":{"S":"<lock-id>"}}' \
  --region us-east-1
```

**Warning:** Only delete locks when you're certain no Terraform process is running!

### Lifecycle Management

S3 bucket lifecycle policies automatically:
- Expire noncurrent versions after 90 days
- Abort incomplete multipart uploads after 7 days

To adjust these settings, modify the `noncurrent_version_expiration_days` variable in the bootstrap configuration.

## Security Best Practices

1. **Access Control**: Use IAM policies to restrict access to state buckets and DynamoDB tables
2. **Audit Logging**: Enable CloudTrail logging for state bucket access
3. **Encryption**: Always use KMS encryption for production environments
4. **Key Rotation**: KMS keys have automatic rotation enabled
5. **Versioning**: Never disable versioning on state buckets
6. **Backup**: Consider additional backup strategies for critical environments

### Recommended IAM Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketVersioning"
      ],
      "Resource": "arn:aws:s3:::tfstate-*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::tfstate-*/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:*:*:table/tf-locks-*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:DescribeKey",
        "kms:GenerateDataKey"
      ],
      "Resource": "arn:aws:kms:*:*:key/*",
      "Condition": {
        "StringEquals": {
          "kms:ViaService": "s3.us-east-1.amazonaws.com"
        }
      }
    }
  ]
}
```

## Troubleshooting

### Issue: "Error acquiring the state lock"
**Solution**: Check if another Terraform process is running. If not, manually delete the lock as described in Lock Management.

### Issue: "Error loading state: access denied"
**Solution**: Verify IAM permissions for S3 bucket and KMS key access.

### Issue: "Backend configuration changed"
**Solution**: Run `terraform init -reconfigure` to reinitialize with the new backend configuration.

### Issue: "Bucket does not exist"
**Solution**: Run the bootstrap process to create the backend infrastructure.

## Maintenance

### Regular Tasks
- [ ] Review S3 bucket size monthly
- [ ] Check DynamoDB usage and costs
- [ ] Audit access logs quarterly
- [ ] Verify KMS key rotation is active
- [ ] Test state recovery procedures annually

### Updates
When modifying the backend configuration:
1. Update the bootstrap Terraform code
2. Apply changes using `terraform apply`
3. Update environment `backend.tf` files if needed
4. Run `terraform init -reconfigure` in each environment
5. Update this documentation

## Support

For issues or questions about the Terraform backend:
1. Check this documentation
2. Review Terraform logs: `TF_LOG=DEBUG terraform <command>`
3. Consult the team's Terraform guidelines
4. Open an issue in the repository

## References

- [Terraform S3 Backend Documentation](https://www.terraform.io/docs/language/settings/backends/s3.html)
- [AWS S3 Versioning](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Versioning.html)
- [AWS DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html)
- [AWS KMS](https://docs.aws.amazon.com/kms/latest/developerguide/overview.html)
