# EHR AWS Environment Pipelines

Infrastructure as Code (IaC) repository for managing AWS environments using Terraform. This repository contains reusable Terraform modules and environment-specific configurations for deploying AWS infrastructure.

## 🏗️ Structure

```
.
├── modules/              # Reusable Terraform modules
│   └── vpc/             # VPC module (public subnets, IGW, S3 endpoint)
├── environments/        # Environment-specific configurations
│   └── courses/        # Courses lab environment
└── README.md
```

## 🚀 Quick Start

### Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- AWS account access

### Deploy Courses Environment

```bash
cd environments/courses
terraform init
terraform plan
terraform apply
```

## 📦 Modules

### VPC Module

A lightweight, cost-optimized VPC module designed for lab and development environments.

**Features:**
- Public subnets with Internet Gateway
- No NAT Gateway (saves ~$35-$40/month)
- Free S3 Gateway Endpoint
- Multi-AZ support
- Fully tagged resources

**Documentation:** [modules/vpc/README.md](modules/vpc/README.md)

**Usage Example:**
```hcl
module "vpc" {
  source = "../../modules/vpc"

  environment = "courses"
  region      = "us-east-1"
  
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  
  enable_nat          = false
  public_subnets_only = true
  enable_s3_endpoint  = true
}
```

## 🌍 Environments

### Courses

Lab environment for AWS courses, demos, and testing.

- **Region:** us-east-1
- **VPC CIDR:** 10.0.0.0/16
- **Cost:** Free tier eligible (~$0/month)
- **Purpose:** Learning, testing, course demos

**Documentation:** [environments/courses/README.md](environments/courses/README.md)

## 💰 Cost Optimization

All environments are designed with cost optimization in mind:

- ✅ No NAT Gateways (saves ~$35-$40/month per AZ)
- ✅ Free S3 Gateway Endpoints
- ✅ Public subnets for direct internet access
- ✅ Free tier eligible resources

**Expected monthly cost for courses environment: $0** (excluding data transfer and service usage)

## 🔒 Security Best Practices

1. **Use SSM Session Manager** instead of SSH/RDP for EC2 access
2. **Apply least privilege** IAM policies
3. **Use security groups** to control traffic
4. **Enable CloudTrail** for audit logging
5. **Use IAM roles** instead of access keys

## 🧪 Testing & Validation

### Validate Terraform Configuration

```bash
terraform fmt -check -recursive
terraform validate
```

### Test Internet Connectivity

```bash
# Deploy test instance in public subnet
# Connect via SSM Session Manager
# Test: curl -I https://www.google.com
```

### Test AWS Service Access

```bash
aws s3 ls
aws dynamodb list-tables
```

## 📚 Documentation

- [VPC Module Documentation](modules/vpc/README.md)
- [Courses Environment Guide](environments/courses/README.md)
- [AWS VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 🛠️ Development

### Adding a New Module

1. Create module directory under `modules/`
2. Add `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`
3. Document in module README.md
4. Add usage example

### Adding a New Environment

1. Create environment directory under `environments/`
2. Add configuration files (main.tf, variables.tf, outputs.tf, versions.tf)
3. Document in environment README.md
4. Reference existing modules

## 🤝 Contributing

1. Create a feature branch
2. Make changes
3. Test thoroughly
4. Submit pull request

## 📄 License

MIT

## 👤 Author

@errolhooper
