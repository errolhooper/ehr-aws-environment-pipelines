variable "environment" {
  description = "Environment name (e.g., courses, dev, qa, prod)"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
  default     = []
}

variable "enable_nat" {
  description = "Enable NAT Gateway for private subnets (incurs cost)"
  type        = bool
  default     = false
}

variable "public_subnets_only" {
  description = "Create only public subnets (no private subnets)"
  type        = bool
  default     = true
}

variable "enable_s3_endpoint" {
  description = "Enable S3 Gateway Endpoint (free)"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "project" {
  description = "Project name for tagging"
  type        = string
  default     = "ehr-aws-environment-pipelines"
}

variable "owner" {
  description = "Owner name for tagging"
  type        = string
  default     = "errolhooper"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
