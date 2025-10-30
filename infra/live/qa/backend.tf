# Terraform Backend Configuration for QA Environment
# This file configures remote state storage in S3 with DynamoDB locking
# 
# To initialize this backend:
#   terraform init
#
# Note: The S3 bucket and DynamoDB table must be created first using
# the bootstrap configuration in infra/bootstrap/

terraform {
  backend "s3" {
    bucket         = "tfstate-qa-us-east-1"
    key            = "qa/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "tf-locks-qa"

    # KMS key for encryption (will be created by bootstrap)
    # kms_key_id = "arn:aws:kms:us-east-1:ACCOUNT_ID:key/KEY_ID"
  }
}
