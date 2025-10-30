# Contributing Guide

Thank you for contributing to the EHR AWS Environment Pipelines project! This guide will help you get started.

## 🚀 Getting Started

### Prerequisites

- **Terraform** >= 1.0
- **Git** for version control
- **AWS CLI** (optional, for testing)
- Basic knowledge of Terraform and AWS

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/errolhooper/ehr-aws-environment-pipelines.git
   cd ehr-aws-environment-pipelines
   ```

2. **Install Terraform**
   - Download from [terraform.io](https://www.terraform.io/downloads)
   - Or use a package manager (brew, apt, yum, etc.)

3. **Verify installation**
   ```bash
   terraform version
   ```

## 📝 Making Changes

### Code Style

- Follow Terraform best practices
- Use consistent naming conventions
- Add comments for complex logic
- Keep modules focused and reusable

### Formatting

Always format your code before committing:

```bash
terraform fmt -recursive
```

### Validation

Run validation on all configurations:

```bash
./validate.sh
```

Or manually:

```bash
# For modules
cd modules/vpc
terraform init
terraform validate

# For environments
cd environments/courses
terraform init
terraform validate
```

## 🔀 Workflow

### 1. Create a Branch

```bash
git checkout -b feature/your-feature-name
```

Branch naming conventions:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring

### 2. Make Your Changes

- Keep changes focused and atomic
- Test thoroughly
- Update documentation as needed

### 3. Commit Your Changes

Write clear, descriptive commit messages:

```bash
git add .
git commit -m "Add feature: description of changes"
```

Commit message format:
```
<type>: <subject>

<body>

<footer>
```

Types:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation only
- `style:` - Formatting, missing semicolons, etc.
- `refactor:` - Code refactoring
- `test:` - Adding tests
- `chore:` - Maintenance tasks

Example:
```
feat: Add DynamoDB endpoint support to VPC module

- Add variable for enabling DynamoDB endpoint
- Create aws_vpc_endpoint resource for DynamoDB
- Associate endpoint with route tables
- Update documentation with usage examples

Closes #123
```

### 4. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub with:
- Clear title and description
- Link to related issues
- Screenshots (if applicable)
- Testing evidence

## 📦 Adding a New Module

1. **Create module directory**
   ```bash
   mkdir -p modules/your-module
   cd modules/your-module
   ```

2. **Create required files**
   - `main.tf` - Main resources
   - `variables.tf` - Input variables
   - `outputs.tf` - Output values
   - `versions.tf` - Terraform and provider versions
   - `README.md` - Module documentation

3. **Module structure template**

   **main.tf**:
   ```hcl
   # Resource definitions
   resource "aws_resource" "example" {
     # Configuration
   }
   ```

   **variables.tf**:
   ```hcl
   variable "name" {
     description = "Description of variable"
     type        = string
     default     = "default-value"
   }
   ```

   **outputs.tf**:
   ```hcl
   output "resource_id" {
     description = "Description of output"
     value       = aws_resource.example.id
   }
   ```

   **versions.tf**:
   ```hcl
   terraform {
     required_version = ">= 1.0"

     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = ">= 4.0"
       }
     }
   }
   ```

4. **Document the module**
   
   Include in README.md:
   - Description and purpose
   - Usage examples
   - Input variables table
   - Output values table
   - Requirements
   - Examples

5. **Test the module**
   ```bash
   terraform init
   terraform validate
   terraform fmt
   ```

## 🌍 Adding a New Environment

1. **Create environment directory**
   ```bash
   mkdir -p environments/your-env
   cd environments/your-env
   ```

2. **Create configuration files**
   - `main.tf` - Resource definitions using modules
   - `variables.tf` - Environment-specific variables
   - `outputs.tf` - Environment outputs
   - `versions.tf` - Terraform configuration
   - `README.md` - Environment documentation
   - `terraform.tfvars.example` - Example variables

3. **Reference existing modules**
   ```hcl
   module "vpc" {
     source = "../../modules/vpc"

     environment = var.environment
     region      = var.region
     # Additional configuration
   }
   ```

4. **Document the environment**
   
   Include in README.md:
   - Purpose and use case
   - Prerequisites
   - Usage instructions
   - Configuration options
   - Validation steps

## 🧪 Testing

### Local Testing

1. **Syntax validation**
   ```bash
   terraform validate
   ```

2. **Plan without applying**
   ```bash
   terraform plan
   ```

3. **Cost estimation** (optional)
   ```bash
   # Use Infracost or similar tools
   infracost breakdown --path .
   ```

### Integration Testing

If you have access to an AWS account:

1. Deploy to a test environment
2. Verify resources are created correctly
3. Test functionality
4. Clean up resources

```bash
terraform apply
# Test functionality
terraform destroy
```

## 📚 Documentation

### Module Documentation

Each module must have a `README.md` with:

- **Description**: What the module does
- **Usage**: Basic example
- **Variables**: Input parameters table
- **Outputs**: Output values table
- **Requirements**: Terraform and provider versions
- **Examples**: Multiple usage scenarios
- **Resources**: List of resources created

### Code Comments

- Add comments for complex logic
- Explain non-obvious decisions
- Document assumptions
- Keep comments up to date

## ✅ Checklist Before Submitting

- [ ] Code is formatted (`terraform fmt -recursive`)
- [ ] Code is validated (`terraform validate`)
- [ ] All validation scripts pass (`./validate.sh`)
- [ ] Documentation is updated
- [ ] Examples are provided
- [ ] Commit messages are clear
- [ ] No sensitive data in code
- [ ] `.gitignore` is updated if needed
- [ ] Changes are tested locally

## 🔒 Security

### Best Practices

- Never commit secrets or credentials
- Use AWS IAM roles, not access keys
- Follow principle of least privilege
- Review security group rules
- Enable logging and monitoring

### Secrets Management

- Use AWS Secrets Manager or Parameter Store
- Use Terraform variables for sensitive data
- Add `.tfvars` files to `.gitignore`
- Use environment variables for credentials

Example:
```bash
# Bad
variable "api_key" {
  default = "sk-1234567890abcdef"
}

# Good
variable "api_key" {
  description = "API key from Secrets Manager"
  type        = string
  sensitive   = true
}
```

## 💡 Tips

- Start with existing modules as examples
- Keep modules simple and focused
- Use consistent naming conventions
- Tag all resources appropriately
- Consider cost implications
- Document cost estimates
- Test in non-production first

## 🆘 Getting Help

- **Issues**: Open an issue on GitHub
- **Discussions**: Start a discussion for questions
- **Documentation**: Check module READMEs
- **Terraform Docs**: [terraform.io/docs](https://terraform.io/docs)
- **AWS Docs**: [docs.aws.amazon.com](https://docs.aws.amazon.com)

## 📄 Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Help others learn
- Keep discussions professional

## 📜 License

By contributing, you agree that your contributions will be licensed under the project's MIT License.

## 🙏 Thank You!

Your contributions help make this project better for everyone. Thank you for taking the time to contribute!

---

**Questions?** Open an issue or reach out to @errolhooper
