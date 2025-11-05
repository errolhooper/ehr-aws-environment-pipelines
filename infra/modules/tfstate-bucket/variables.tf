variable "bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, qa, prod, courses)"
  type        = string
}

variable "kms_key_id" {
  description = "ARN of the KMS key to use for encryption. If not provided, AES256 will be used"
  type        = string
  default     = null
}

variable "noncurrent_version_expiration_days" {
  description = "Number of days after which noncurrent versions expire"
  type        = number
  default     = 90
}

variable "enable_logging" {
  description = "Enable S3 access logging"
  type        = bool
  default     = false
}

variable "logging_bucket" {
  description = "S3 bucket to store access logs"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
