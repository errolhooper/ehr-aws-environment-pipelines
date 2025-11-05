# Terraform Backend Bootstrap

This directory contains the Terraform configuration to bootstrap the remote state backend infrastructure for all environments.

## Purpose

This bootstrap configuration creates:
- S3 buckets for Terraform state storage
- DynamoDB tables for state locking
- KMS keys for encryption (optional)

## Usage

### Prerequisites
- AWS CLI configured with appropriate credentials
- Terraform >= 1.0 installed
- AWS account IDs for each environment

### Setup Steps

1. **Update account IDs** in the environment-specific tfvars files:
   - `terraform.tfvars.dev`
   - `terraform.tfvars.qa`
   - `terraform.tfvars.prod`
   - `terraform.tfvars.courses`

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Create backend for an environment**:
   ```bash
   # For development
   terraform apply -var-file=terraform.tfvars.dev
   
   # For QA
   terraform apply -var-file=terraform.tfvars.qa
   
   # For production
   terraform apply -var-file=terraform.tfvars.prod
   
   # For courses
   terraform apply -var-file=terraform.tfvars.courses
   ```

4. **Note the outputs** (bucket ARN, table ARN, KMS key ARN) and update the documentation.

5. **Configure environment backends** in `infra/live/<env>/backend.tf` if needed (e.g., add KMS key ID).

## Important Notes

⚠️ **This bootstrap configuration uses local state** because it creates the remote backend infrastructure. After the backend is created, all other Terraform configurations should use the remote backend.

⚠️ **Run this once per environment** - You only need to run this bootstrap process when setting up a new environment or recreating the backend infrastructure.

⚠️ **Store bootstrap state securely** - The local state file created by this bootstrap process should be stored securely (e.g., in a separate secure S3 bucket or version control with encryption).

## Customization

You can customize the backend configuration by modifying the tfvars files:

- `bucket_name`: Name of the S3 bucket
- `dynamodb_table_name`: Name of the DynamoDB table
- `region`: AWS region
- `create_kms_key`: Whether to create a KMS key (set to `false` to use AES256 encryption)
- `noncurrent_version_expiration_days`: Days before old state versions are deleted
- `enable_point_in_time_recovery`: Enable DynamoDB point-in-time recovery

## Security Features

- ✅ S3 bucket versioning enabled
- ✅ S3 encryption (AES256 or KMS)
- ✅ S3 public access blocked
- ✅ DynamoDB encryption enabled
- ✅ KMS key rotation enabled
- ✅ Lifecycle policies for old versions
- ✅ Point-in-time recovery for DynamoDB

## See Also

- [Terraform Backend Documentation](../../docs/terraform-backend.md) - Complete documentation
- [Terraform S3 Backend](https://www.terraform.io/docs/language/settings/backends/s3.html) - Official docs
