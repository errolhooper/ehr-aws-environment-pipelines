output "bucket_id" {
  description = "ID of the Terraform state S3 bucket"
  value       = module.tfstate_bucket.bucket_id
}

output "bucket_arn" {
  description = "ARN of the Terraform state S3 bucket"
  value       = module.tfstate_bucket.bucket_arn
}

output "bucket_name" {
  description = "Name of the Terraform state S3 bucket"
  value       = module.tfstate_bucket.bucket_name
}

output "dynamodb_table_id" {
  description = "ID of the DynamoDB lock table"
  value       = module.tfstate_lock.table_id
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB lock table"
  value       = module.tfstate_lock.table_arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB lock table"
  value       = module.tfstate_lock.table_name
}

output "kms_key_id" {
  description = "ID of the KMS key used for state bucket encryption"
  value       = var.create_kms_key ? aws_kms_key.terraform_state[0].id : null
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for state bucket encryption"
  value       = var.create_kms_key ? aws_kms_key.terraform_state[0].arn : null
}
