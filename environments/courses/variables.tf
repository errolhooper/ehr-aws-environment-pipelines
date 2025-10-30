variable "region" {
  description = "AWS region for the courses environment"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "courses"
}
