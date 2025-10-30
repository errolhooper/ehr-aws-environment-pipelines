# AWS VPC Terraform Module

A lightweight, cost-optimized Terraform module for creating AWS VPCs with public subnets and Internet Gateway access. Perfect for lab environments, course demos, and development workloads.

## Features

- ✅ **Public subnets with Internet Gateway** for outbound internet access
- ✅ **No NAT Gateway** - saves ~$35-$40/month
- ✅ **Free S3 Gateway Endpoint** to reduce data transfer costs
- ✅ **Multi-AZ support** for high availability
- ✅ **DNS support enabled** for hostname resolution
- ✅ **Fully tagged resources** for cost tracking and management
- ✅ **Reusable and customizable** for different environments

## Usage

### Basic Example (Courses Environment)

```hcl
module "vpc" {
  source = "../../modules/vpc"

  environment = "courses"
  region      = "us-east-1"

  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  
  # Cost optimization settings
  enable_nat           = false
  public_subnets_only  = true
  enable_s3_endpoint   = true

  # Tags
  project = "ehr-aws-environment-pipelines"
  owner   = "errolhooper"
}
```

### With Custom Availability Zones

```hcl
module "vpc" {
  source = "../../modules/vpc"

  environment        = "dev"
  region             = "us-west-2"
  availability_zones = ["us-west-2a", "us-west-2b"]

  vpc_cidr            = "10.1.0.0/16"
  public_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| environment | Environment name (e.g., courses, dev, qa, prod) | `string` | - | yes |
| region | AWS region | `string` | - | yes |
| vpc_cidr | CIDR block for VPC | `string` | `"10.0.0.0/16"` | no |
| public_subnet_cidrs | CIDR blocks for public subnets | `list(string)` | `["10.0.1.0/24", "10.0.2.0/24"]` | no |
| availability_zones | Availability zones for subnets | `list(string)` | `[]` (auto-detect) | no |
| enable_nat | Enable NAT Gateway for private subnets (incurs cost) | `bool` | `false` | no |
| public_subnets_only | Create only public subnets (no private subnets) | `bool` | `true` | no |
| enable_s3_endpoint | Enable S3 Gateway Endpoint (free) | `bool` | `true` | no |
| enable_dns_support | Enable DNS support in the VPC | `bool` | `true` | no |
| enable_dns_hostnames | Enable DNS hostnames in the VPC | `bool` | `true` | no |
| project | Project name for tagging | `string` | `"ehr-aws-environment-pipelines"` | no |
| owner | Owner name for tagging | `string` | `"errolhooper"` | no |
| tags | Additional tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_cidr | The CIDR block of the VPC |
| vpc_arn | The ARN of the VPC |
| internet_gateway_id | The ID of the Internet Gateway |
| public_subnet_ids | List of IDs of public subnets |
| public_subnet_cidrs | List of CIDR blocks of public subnets |
| public_subnet_arns | List of ARNs of public subnets |
| public_route_table_id | ID of the public route table |
| public_route_table_ids | List of IDs of public route tables |
| availability_zones | List of availability zones used by subnets |
| s3_endpoint_id | The ID of the S3 VPC endpoint |
| s3_endpoint_prefix_list_id | The prefix list ID of the S3 VPC endpoint |

## Architecture

This module creates:

1. **VPC** with DNS support and hostnames enabled
2. **Internet Gateway** attached to the VPC
3. **Public Subnets** (default: 2) across multiple availability zones
4. **Public Route Table** with a default route to the Internet Gateway
5. **S3 Gateway Endpoint** (optional, enabled by default) for cost-free S3 access

```
┌─────────────────────────────────────────────────┐
│                    VPC                          │
│              (10.0.0.0/16)                      │
│                                                 │
│  ┌──────────────────┐  ┌──────────────────┐   │
│  │  Public Subnet 1 │  │  Public Subnet 2 │   │
│  │  (10.0.1.0/24)   │  │  (10.0.2.0/24)   │   │
│  │  AZ-a            │  │  AZ-b            │   │
│  └────────┬─────────┘  └────────┬─────────┘   │
│           │                     │              │
│           └──────────┬──────────┘              │
│                      │                         │
│          ┌───────────▼──────────┐              │
│          │  Public Route Table  │              │
│          │  0.0.0.0/0 → IGW    │              │
│          └───────────┬──────────┘              │
│                      │                         │
└──────────────────────┼─────────────────────────┘
                       │
              ┌────────▼────────┐
              │ Internet Gateway│
              └────────┬────────┘
                       │
                   Internet
```

## Cost Optimization

This module is designed for **minimal cost**:

- ❌ **No NAT Gateway** (~$32/month base + data transfer)
- ✅ **S3 Gateway Endpoint** (free) reduces data transfer costs
- ✅ **Public subnets only** - no private subnet infrastructure
- ✅ **Internet Gateway** (free, data transfer only)

### Expected Costs
- **VPC**: Free
- **Subnets**: Free
- **Internet Gateway**: Free (data transfer charges apply)
- **S3 Gateway Endpoint**: Free
- **Route Tables**: Free

**Total monthly cost: $0** (excluding data transfer)

## Use Cases

Perfect for:
- 🎓 **Learning and courses** - AWS service demos and tutorials
- 🧪 **Lab environments** - testing AWS services
- 🚀 **Proof of concepts** - quick prototypes
- 💻 **Development workloads** - Lambda, Bedrock, Glue, SageMaker
- 📊 **Data processing** - EMR, Glue, Athena

## Access Patterns

### SSH/RDP Access
Use **AWS Systems Manager Session Manager** instead of traditional SSH/RDP:
- No need for bastion hosts
- No inbound security group rules required
- Audit logging included
- Free to use

### AWS Service Access
All AWS services are accessible via their public endpoints:
- ✅ S3 (via Gateway Endpoint)
- ✅ DynamoDB (via public endpoint)
- ✅ Lambda (deployed in public subnets)
- ✅ Bedrock (via public endpoint)
- ✅ SageMaker (via public endpoint)
- ✅ Glue (via public endpoint)

## Security Considerations

1. **Public Subnets**: All instances receive public IPs - use security groups carefully
2. **No Private Subnets**: Not suitable for production workloads requiring network isolation
3. **Internet Access**: Direct outbound internet access - monitor for data exfiltration
4. **SSM Access**: Ensure IAM roles have `AmazonSSMManagedInstanceCore` policy

## Future Enhancements

This module supports adding:
- Private subnets (set `public_subnets_only = false`)
- NAT Gateway (set `enable_nat = true`)
- Additional VPC endpoints (DynamoDB, etc.)
- Network ACLs for additional security
- VPC Flow Logs for monitoring

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Resources Created

- `aws_vpc`
- `aws_internet_gateway`
- `aws_subnet` (public)
- `aws_route_table` (public)
- `aws_route` (default route)
- `aws_route_table_association`
- `aws_vpc_endpoint` (S3, optional)
- `aws_vpc_endpoint_route_table_association`

## References

- [AWS Free Tier](https://aws.amazon.com/free/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [S3 Gateway Endpoints](https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints-s3.html)

## License

MIT

## Author

@errolhooper
