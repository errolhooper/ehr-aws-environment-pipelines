variable "table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, qa, prod, courses)"
  type        = string
}

variable "enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery for DynamoDB table"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
