# Create VPC using our module
module "vpc" {
  source = "../../modules/vpc"

  environment = var.environment
  region      = var.region

  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]

  enable_nat          = false
  public_subnets_only = true
  enable_s3_endpoint  = true

  project = "lambda-vpc-example"
  owner   = "terraform"
}

# Security Group for Lambda
resource "aws_security_group" "lambda" {
  name        = "${var.environment}-lambda-sg"
  description = "Security group for Lambda function"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.environment}-lambda-sg"
    Environment = var.environment
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda" {
  name = "${var.environment}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-lambda-role"
    Environment = var.environment
  }
}

# Attach AWS managed policy for VPC execution
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.environment}-vpc-lambda"
  retention_in_days = 7

  tags = {
    Name        = "${var.environment}-lambda-logs"
    Environment = var.environment
  }
}

# Lambda Function
resource "aws_lambda_function" "example" {
  filename      = "${path.module}/lambda_placeholder.zip"
  function_name = "${var.environment}-vpc-lambda"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  timeout       = 30
  memory_size   = 128

  vpc_config {
    subnet_ids         = module.vpc.public_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      ENVIRONMENT = var.environment
      VPC_ID      = module.vpc.vpc_id
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_iam_role_policy_attachment.lambda_vpc
  ]

  tags = {
    Name        = "${var.environment}-vpc-lambda"
    Environment = var.environment
  }
}

# Create placeholder Lambda code if it doesn't exist
resource "null_resource" "lambda_placeholder" {
  provisioner "local-exec" {
    command = <<EOF
      if [ ! -f "${path.module}/lambda_placeholder.zip" ]; then
        echo 'def handler(event, context):
    return {
        "statusCode": 200,
        "body": "Hello from Lambda in VPC!"
    }' > /tmp/lambda_index.py
        cd /tmp && zip ${path.module}/lambda_placeholder.zip lambda_index.py
        rm /tmp/lambda_index.py
      fi
    EOF
  }
}

# Ensure placeholder is created before Lambda
resource "terraform_data" "lambda_code_dependency" {
  depends_on = [null_resource.lambda_placeholder]
}
