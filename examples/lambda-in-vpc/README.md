# Lambda Function in VPC Example

This example demonstrates how to deploy an AWS Lambda function in the VPC created by our module.

## Overview

- Creates a VPC using the vpc module
- Deploys a Lambda function in public subnets
- Configures security group for Lambda
- Sets up IAM role with necessary permissions

## Architecture

```
VPC (10.0.0.0/16)
  ├── Public Subnet 1 (10.0.1.0/24)
  │   └── Lambda Function
  └── Public Subnet 2 (10.0.2.0/24)
      └── Lambda Function (for HA)
```

## Prerequisites

- Terraform >= 1.0
- AWS credentials configured
- Lambda function code (see `lambda.zip` or use the placeholder)

## Usage

1. **Create Lambda deployment package** (optional - example uses inline code):
   ```bash
   # If you want to deploy custom code
   zip lambda.zip index.js
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Plan deployment**:
   ```bash
   terraform plan
   ```

4. **Apply configuration**:
   ```bash
   terraform apply
   ```

5. **Test the function**:
   ```bash
   aws lambda invoke \
     --function-name example-vpc-lambda \
     --payload '{"key": "value"}' \
     response.json
   cat response.json
   ```

6. **Clean up**:
   ```bash
   terraform destroy
   ```

## What Gets Created

- VPC with public subnets
- Internet Gateway
- S3 Gateway Endpoint
- Lambda function in VPC
- IAM role for Lambda
- Security group for Lambda
- CloudWatch Log Group

## Cost

- **VPC**: Free
- **Lambda**: Free tier includes 1M requests/month
- **CloudWatch Logs**: First 5GB ingestion free
- **Total**: ~$0/month within free tier

## Notes

- Lambda in public subnets needs Internet Gateway for AWS service access
- For Lambda accessing private resources (RDS, etc.), use private subnets with NAT
- This example is for learning purposes - production workloads should follow security best practices

## Customization

Edit `main.tf` to:
- Change Lambda runtime
- Modify memory/timeout settings
- Add environment variables
- Configure additional triggers
- Add VPC endpoints for other services
