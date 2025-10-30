# Courses Environment VPC

This directory contains the Terraform configuration for the **courses** AWS account VPC - a lightweight lab environment for testing AWS services and building course demos.

## Architecture

- **VPC CIDR**: 10.0.0.0/16
- **Public Subnets**: 2 across different AZs (10.0.1.0/24, 10.0.2.0/24)
- **Internet Access**: Internet Gateway (free)
- **S3 Access**: S3 Gateway Endpoint (free)
- **No NAT Gateway**: Saves ~$35-$40/month

## Prerequisites

1. **Terraform** >= 1.0 installed
2. **AWS CLI** configured with credentials for the courses account
3. Appropriate IAM permissions to create VPC resources

## Usage

### Initialize Terraform

```bash
cd environments/courses
terraform init
```

### Plan Changes

```bash
terraform plan
```

### Apply Configuration

```bash
terraform apply
```

### Destroy Resources

```bash
terraform destroy
```

## Configuration

### Default Values

- **Region**: us-east-1
- **Environment**: courses
- **VPC CIDR**: 10.0.0.0/16
- **Public Subnets**: 10.0.1.0/24, 10.0.2.0/24

### Customization

You can override defaults by:

1. **Creating a terraform.tfvars file**:
```hcl
region = "us-west-2"
```

2. **Using -var flag**:
```bash
terraform apply -var="region=us-west-2"
```

3. **Environment variables**:
```bash
export TF_VAR_region="us-west-2"
terraform apply
```

## Outputs

After deployment, Terraform will output:

- VPC ID
- Public subnet IDs
- Internet Gateway ID
- Route table IDs
- S3 endpoint ID
- Availability zones

View outputs anytime:
```bash
terraform output
```

## Cost

**Expected monthly cost: $0** (free tier eligible)

The only costs are:
- Data transfer out to the internet (first 100 GB/month free)
- AWS service usage (EC2, Lambda, etc.)

## Security

### Best Practices

1. **Use Security Groups**: Control inbound/outbound traffic at instance level
2. **SSM Session Manager**: Use instead of SSH for EC2 access (no bastion host needed)
3. **IAM Roles**: Attach roles to instances rather than using access keys
4. **Least Privilege**: Grant only necessary permissions

### Security Group Example

```hcl
resource "aws_security_group" "example" {
  name        = "example-sg"
  description = "Example security group"
  vpc_id      = module.vpc.vpc_id

  # Allow outbound to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # No inbound rules - use SSM for access
}
```

## Common Use Cases

### Lambda Functions

```hcl
resource "aws_lambda_function" "example" {
  function_name = "example-function"
  role          = aws_iam_role.lambda.arn
  
  vpc_config {
    subnet_ids         = module.vpc.public_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }
}
```

### EC2 Instances

```hcl
resource "aws_instance" "example" {
  ami                    = "ami-xxxxxxxxx"
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.example.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm.name
  
  # SSM access enabled via IAM role
}
```

### RDS Database (Public Access for Lab)

```hcl
resource "aws_db_subnet_group" "example" {
  name       = "example-db-subnet"
  subnet_ids = module.vpc.public_subnet_ids
}

resource "aws_db_instance" "example" {
  allocated_storage      = 20
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  db_subnet_group_name   = aws_db_subnet_group.example.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = true  # Lab environment only!
}
```

## State Management

### Local State (Default)

By default, state is stored locally in `terraform.tfstate`. This is fine for personal use but:

⚠️ **Warning**: Don't commit `terraform.tfstate` to git (already in .gitignore)

### Remote State (Recommended)

For team collaboration, use S3 backend:

1. Create an S3 bucket for state:
```bash
aws s3 mb s3://your-terraform-state-bucket
```

2. Uncomment the backend configuration in `versions.tf`:
```hcl
backend "s3" {
  bucket = "your-terraform-state-bucket"
  key    = "courses/vpc/terraform.tfstate"
  region = "us-east-1"
}
```

3. Initialize with backend:
```bash
terraform init -migrate-state
```

## Validation

### Test Internet Connectivity

Deploy a test EC2 instance:

```bash
# Create a test instance
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t2.micro \
  --subnet-id $(terraform output -raw public_subnet_ids | jq -r '.[0]')

# Connect via SSM
aws ssm start-session --target <instance-id>

# Test internet access
curl -I https://www.google.com
```

### Test AWS Service Access

```bash
# Test S3 access
aws s3 ls

# Test DynamoDB access
aws dynamodb list-tables

# Test Bedrock access
aws bedrock list-foundation-models
```

## Troubleshooting

### Internet Gateway Not Working

1. Verify route table has default route:
```bash
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$(terraform output -raw vpc_id)"
```

2. Check security group allows outbound traffic

3. Ensure instance has public IP (auto-assigned in public subnets)

### Cannot Access AWS Services

1. Verify IAM role has necessary permissions
2. Check VPC endpoint configuration for S3
3. Ensure security group allows HTTPS (443) outbound

## Cleanup

To remove all resources:

```bash
terraform destroy
```

⚠️ **Warning**: This will delete the VPC and all associated resources. Make sure no workloads are running.

## Support

For issues or questions:
- Open an issue on GitHub
- Contact: @errolhooper

## References

- [Module Documentation](../../modules/vpc/README.md)
- [AWS VPC Pricing](https://aws.amazon.com/vpc/pricing/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
