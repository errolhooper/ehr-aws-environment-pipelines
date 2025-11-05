output "table_id" {
  description = "ID of the DynamoDB table"
  value       = aws_dynamodb_table.terraform_locks.id
}

output "table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.terraform_locks.arn
}

output "table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.terraform_locks.name
}
