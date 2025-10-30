module "vpc" {
  source = "../../modules/vpc"

  environment = var.environment
  region      = var.region

  # Network configuration
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]

  # Cost optimization - no NAT Gateway
  enable_nat          = false
  public_subnets_only = true

  # Enable free S3 endpoint
  enable_s3_endpoint = true

  # DNS configuration
  enable_dns_support   = true
  enable_dns_hostnames = true

  # Tags
  project = "ehr-aws-environment-pipelines"
  owner   = "errolhooper"

  tags = {
    CostCenter = "courses"
    Purpose    = "lab-environment"
  }
}
