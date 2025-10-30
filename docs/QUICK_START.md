# Quick Start Guide

This guide will help you get started with the Terraform backend infrastructure quickly.

## Step 1: Install Prerequisites

```bash
# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Verify installation
terraform version

# Configure AWS CLI (if not already done)
aws configure
```

## Step 2: Bootstrap Backend Infrastructure

```bash
# Navigate to bootstrap directory
cd infra/bootstrap

# Edit the tfvars file for your environment
# Replace REPLACE_WITH_DEV_ACCOUNT_ID with your actual AWS account ID
vim terraform.tfvars.dev

# Initialize Terraform
terraform init

# Review the plan
terraform plan -var-file=terraform.tfvars.dev

# Apply the configuration
terraform apply -var-file=terraform.tfvars.dev

# Note the outputs (bucket name, DynamoDB table name, KMS key ARN)
```

## Step 3: Verify Backend Resources

```bash
# Check S3 bucket
aws s3 ls s3://tfstate-dev-us-east-1

# Check DynamoDB table
aws dynamodb describe-table --table-name tf-locks-dev --region us-east-1

# Check KMS key
aws kms describe-key --key-id alias/terraform-state-dev --region us-east-1
```

## Step 4: Initialize Environment

```bash
# Navigate to dev environment
cd ../live/dev

# Initialize with backend
terraform init

# Verify backend is configured
terraform state list

# The output should show that state is stored remotely
```

## Step 5: Test State Locking

Open two terminal windows and try to run Terraform operations simultaneously:

**Terminal 1:**
```bash
cd infra/live/dev
terraform plan
```

**Terminal 2:**
```bash
cd infra/live/dev
terraform plan
```

You should see a lock error in one terminal, confirming that state locking is working.

## Step 6: Repeat for Other Environments

```bash
# For QA environment
cd infra/bootstrap
terraform apply -var-file=terraform.tfvars.qa

# For Prod environment
terraform apply -var-file=terraform.tfvars.prod

# For Courses environment
terraform apply -var-file=terraform.tfvars.courses
```

## Common Issues

### Issue: "Bucket already exists"
**Solution**: The bucket name must be globally unique. Update the bucket name in the tfvars file.

### Issue: "Access denied"
**Solution**: Ensure your AWS credentials have permissions to create S3 buckets, DynamoDB tables, and KMS keys.

### Issue: "Region not available"
**Solution**: Update the region in the tfvars file to an available region in your account.

## Next Steps

1. Add your infrastructure code to the environment directories
2. Review the [main README](../../README.md) for best practices
3. Read the [backend documentation](../../docs/terraform-backend.md) for detailed information

## Quick Reference

| Environment | S3 Bucket | DynamoDB Table |
|-------------|-----------|----------------|
| Dev | `tfstate-dev-us-east-1` | `tf-locks-dev` |
| QA | `tfstate-qa-us-east-1` | `tf-locks-qa` |
| Prod | `tfstate-prod-us-east-1` | `tf-locks-prod` |
| Courses | `tfstate-courses-us-east-1` | `tf-locks-courses` |

## Helpful Commands

```bash
# Format all Terraform files
terraform fmt -recursive

# Validate configuration
terraform validate

# Show state
terraform show

# List resources in state
terraform state list

# Remove a resource from state (doesn't destroy it)
terraform state rm <resource>
```
