# EHR AWS Environment Pipelines

Infrastructure as Code (IaC) repository for managing AWS environments for the EHR project using Terraform.

## Overview

This repository contains Terraform configurations for managing infrastructure across multiple environments:
- **Development (dev)**
- **QA (qa)**
- **Production (prod)**
- **Courses (courses)**

## Repository Structure

```
.
├── docs/                          # Documentation
│   └── terraform-backend.md      # Backend configuration docs
├── infra/
│   ├── bootstrap/                # Bootstrap Terraform state backend
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── terraform.tfvars.dev
│   │   ├── terraform.tfvars.qa
│   │   ├── terraform.tfvars.prod
│   │   ├── terraform.tfvars.courses
│   │   └── README.md
│   ├── modules/                  # Reusable Terraform modules
│   │   ├── tfstate-bucket/       # S3 state bucket module
│   │   └── tfstate-lock/         # DynamoDB lock table module
│   └── live/                     # Environment-specific configurations
│       ├── dev/
│       │   ├── backend.tf        # Backend configuration
│       │   └── main.tf           # Main infrastructure
│       ├── qa/
│       │   ├── backend.tf
│       │   └── main.tf
│       ├── prod/
│       │   ├── backend.tf
│       │   └── main.tf
│       └── courses/
│           ├── backend.tf
│           └── main.tf
└── README.md
```

## Getting Started

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- AWS account access with necessary permissions

### Initial Setup

Before you can use Terraform with remote state, you must bootstrap the backend infrastructure:

1. **Navigate to the bootstrap directory:**
   ```bash
   cd infra/bootstrap
   ```

2. **Update the account IDs** in the tfvars files:
   - `terraform.tfvars.dev`
   - `terraform.tfvars.qa`
   - `terraform.tfvars.prod`
   - `terraform.tfvars.courses`

3. **Initialize and apply the bootstrap configuration:**
   ```bash
   # Initialize Terraform
   terraform init
   
   # Create backend for development
   terraform apply -var-file=terraform.tfvars.dev
   
   # Repeat for other environments as needed
   terraform apply -var-file=terraform.tfvars.qa
   terraform apply -var-file=terraform.tfvars.prod
   terraform apply -var-file=terraform.tfvars.courses
   ```

4. **Verify the backend resources were created:**
   - S3 buckets: `tfstate-{env}-us-east-1`
   - DynamoDB tables: `tf-locks-{env}`

### Working with Environments

Once the backend is bootstrapped, you can work with each environment:

```bash
# Navigate to an environment
cd infra/live/dev

# Initialize Terraform (this will configure the S3 backend)
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply
```

## Terraform Backend

Each environment uses remote state stored in S3 with DynamoDB for state locking:

- **S3 Buckets**: Store Terraform state files
  - `tfstate-dev-us-east-1`
  - `tfstate-qa-us-east-1`
  - `tfstate-prod-us-east-1`
  - `tfstate-courses-us-east-1`

- **DynamoDB Tables**: Provide state locking
  - `tf-locks-dev`
  - `tf-locks-qa`
  - `tf-locks-prod`
  - `tf-locks-courses`

For detailed backend documentation, see [docs/terraform-backend.md](docs/terraform-backend.md).

## Security Features

- ✅ S3 bucket encryption (AES-256 or KMS)
- ✅ S3 versioning enabled
- ✅ S3 public access blocked
- ✅ DynamoDB encryption enabled
- ✅ KMS key rotation enabled
- ✅ Lifecycle policies for old state versions
- ✅ Point-in-time recovery for DynamoDB

## Best Practices

1. **Always use the correct environment**: Double-check you're in the right directory before running Terraform commands
2. **Review plans carefully**: Always run `terraform plan` before `apply`
3. **Use workspaces cautiously**: We use separate directories for environments, not workspaces
4. **Keep modules DRY**: Reuse modules from `infra/modules/` when possible
5. **Document changes**: Update relevant documentation when making infrastructure changes
6. **Lock file management**: Commit `.terraform.lock.hcl` files to ensure consistent provider versions

## Common Commands

```bash
# Format Terraform files
terraform fmt -recursive

# Validate configuration
terraform validate

# View current state
terraform state list

# Show specific resource
terraform state show <resource>

# Plan with detailed output
terraform plan -out=tfplan

# Apply saved plan
terraform apply tfplan
```

## Troubleshooting

### State Lock Issues
If you encounter a state lock error:
```bash
# Force unlock (use with caution!)
terraform force-unlock <lock-id>
```

### Backend Configuration Changes
If backend configuration changes:
```bash
terraform init -reconfigure
```

### Debugging
Enable debug logging:
```bash
export TF_LOG=DEBUG
terraform <command>
```

## Contributing

1. Create a feature branch
2. Make your changes
3. Run `terraform fmt` and `terraform validate`
4. Test in dev environment first
5. Submit a pull request

## Documentation

- [Terraform Backend Documentation](docs/terraform-backend.md)
- [Bootstrap README](infra/bootstrap/README.md)

## Support

For issues or questions:
1. Check the documentation
2. Review Terraform logs with `TF_LOG=DEBUG`
3. Open an issue in this repository

## License

[Add your license information here]
