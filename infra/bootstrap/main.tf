terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Project     = "EHR-AWS-Environment-Pipelines"
      Environment = var.environment
    }
  }
}

# KMS Key for S3 bucket encryption (optional but recommended for production)
resource "aws_kms_key" "terraform_state" {
  count = var.create_kms_key ? 1 : 0

  description             = "KMS key for Terraform state bucket encryption in ${var.environment}"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name        = "terraform-state-${var.environment}"
    Purpose     = "Terraform State Encryption"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "terraform_state" {
  count = var.create_kms_key ? 1 : 0

  name          = "alias/terraform-state-${var.environment}"
  target_key_id = aws_kms_key.terraform_state[0].key_id
}

# S3 Bucket for Terraform State
module "tfstate_bucket" {
  source = "../modules/tfstate-bucket"

  bucket_name                        = var.bucket_name
  environment                        = var.environment
  kms_key_id                         = var.create_kms_key ? aws_kms_key.terraform_state[0].arn : null
  noncurrent_version_expiration_days = var.noncurrent_version_expiration_days

  tags = var.tags
}

# DynamoDB Table for State Locking
module "tfstate_lock" {
  source = "../modules/tfstate-lock"

  table_name                    = var.dynamodb_table_name
  environment                   = var.environment
  enable_point_in_time_recovery = var.enable_point_in_time_recovery

  tags = var.tags
}
