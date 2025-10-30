output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "subnet_ids" {
  description = "Subnet IDs where Lambda is deployed"
  value       = module.vpc.public_subnet_ids
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.example.function_name
}

output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.example.arn
}

output "security_group_id" {
  description = "Security group ID for Lambda"
  value       = aws_security_group.lambda.id
}
