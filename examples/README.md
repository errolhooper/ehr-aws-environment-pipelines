# Examples

This directory contains example configurations demonstrating how to use the Terraform modules in this repository.

## Available Examples

### 1. Lambda Function in VPC

**Directory:** `lambda-in-vpc/`

Demonstrates how to deploy an AWS Lambda function within a VPC using the vpc module.

**What it shows:**
- VPC creation with public subnets
- Lambda function deployment in VPC
- Security group configuration
- IAM role setup for Lambda
- CloudWatch logging

**Cost:** Free tier eligible (~$0/month)

**Quick start:**
```bash
cd lambda-in-vpc
terraform init
terraform apply
```

## Using Examples

### Prerequisites

All examples require:
- Terraform >= 1.0
- AWS CLI configured with credentials
- Appropriate IAM permissions

### General Workflow

1. **Navigate to example directory**
   ```bash
   cd examples/<example-name>
   ```

2. **Review the configuration**
   ```bash
   cat README.md
   cat main.tf
   ```

3. **Initialize Terraform**
   ```bash
   terraform init
   ```

4. **Review the plan**
   ```bash
   terraform plan
   ```

5. **Apply (if desired)**
   ```bash
   terraform apply
   ```

6. **Test the deployment**
   - Follow testing instructions in the example's README

7. **Clean up**
   ```bash
   terraform destroy
   ```

## Cost Considerations

All examples are designed to be:
- ✅ Free tier eligible where possible
- ✅ Low cost for testing purposes
- ✅ Easy to destroy after testing

**Always remember to run `terraform destroy` after testing to avoid unexpected charges.**

## Example Structure

Each example follows this structure:

```
example-name/
├── README.md           # Example documentation
├── main.tf            # Main configuration
├── variables.tf       # Input variables
├── outputs.tf         # Output values
└── versions.tf        # Terraform/provider versions
```

## Contributing Examples

Have a useful example to share? See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on adding new examples.

### Example Checklist

When creating a new example:

- [ ] Clear, focused use case
- [ ] Complete documentation (README.md)
- [ ] Working configuration (tested)
- [ ] Input variables with defaults
- [ ] Useful outputs
- [ ] Cost estimate
- [ ] Cleanup instructions
- [ ] Tags for resource management

## Support

For questions or issues with examples:
- Check the example's README.md
- Review module documentation
- Open an issue on GitHub

## Additional Resources

- [Module Documentation](../modules/vpc/README.md)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Documentation](https://docs.aws.amazon.com)
