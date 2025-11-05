# Terraform Backend Configuration for Development Environment
# This file configures remote state storage in S3 with DynamoDB locking
# 
# To initialize this backend:
#   terraform init
#
# Note: The S3 bucket and DynamoDB table must be created first using
# the bootstrap configuration in infra/bootstrap/

terraform {
  backend "s3" {
    bucket         = "tfstate-dev-us-east-1"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "tf-locks-dev"

    # KMS key for encryption (will be created by bootstrap)
    # kms_key_id = "arn:aws:kms:us-east-1:ACCOUNT_ID:key/KEY_ID"
  }
}
