# Terraform configuration block specifying the required version and providers.
terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

# AWS provider configuration with region and credentials.
provider "aws" {
  region     = "us-west-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

#====================================

# Network module configuration.
module "network" {
  source = "./modules/network"

  availability_zones = var.availability_zones
  cidr_block         = var.cidr_block
}

#====================================

# Security module configuration.
module "security" {
  source = "./modules/security"

  vpc_id = module.network.vpc_id

  depends_on = [
    module.network
  ]
}

#====================================

# S3 module configuration.
module "s3" {
  source = "./modules/s3"
}

# SNS module configuration.
module "sns" {
  source = "./modules/sns"
  name   = "address-info-sns-topic"
}

# DynamoDB module configuration with table name, hash key, and environment.
module "dynamodb" {
  source              = "./modules/dynamodb"
  dynamodb_table_name = "address-info-table"
  hash_key            = "id"
  hash_key_type       = "S"
  environment         = "Dev"
}

# Lambda module configuration, passing S3 bucket ARN, IAM role ARN, and DynamoDB table name.
module "lambda" {
  source              = "./modules/lambda"
  s3_bucket_arn       = module.s3.bucket_arn
  iam_role_arn        = module.iam.lambda_exec_role_arn
  dynamodb_table_name = module.dynamodb.dynamodb_table_name
  sns_topic_arn       = module.sns.arn
}

# IAM module configuration, passing S3 bucket ARN and DynamoDB table ARN.
module "iam" {
  source             = "./modules/iam"
  s3_bucket_arn      = module.s3.bucket_arn
  dynamodb_table_arn = module.dynamodb.dynamodb_table_arn
  sns_topic_arn      = module.sns.arn
}

# EC2 module configuration, including user data for instance initialization.
module "ec2" {
  source   = "./modules/ec2"
  key_name = var.key_name
  user_data = base64encode(templatefile("server-user-data.sh.tpl", {
    sns_topic_arn       = module.sns.arn,
    aws_access_key      = var.aws_access_key,
    aws_secret_key      = var.aws_secret_key,
    s3_bucket_name      = module.s3.bucket_name,
    dynamodb_table_name = module.dynamodb.dynamodb_table_name,
    server_js_content   = file("${path.module}/server.js")
  }))
  instance_type   = var.app_instance_type
  vpc_id          = module.network.vpc_id
  public_subnets  = module.network.public_subnets
  private_subnets = module.network.private_subnets
  webserver_sg_id = module.security.application_sg_id
  alb_sg_id       = module.security.alb_sg_id
  depends_on = [
    module.network,
    module.security
  ]
}

# AWS S3 bucket notification resource to trigger Lambda function on object creation events.
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = module.s3.bucket_name

  lambda_function {
    lambda_function_arn = module.lambda.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv"
  }

  depends_on = [module.lambda]
}

# SNS topic subscription to forward messages to the ALB endpoint.
resource "aws_sns_topic_subscription" "alb_subscription" {
  topic_arn  = module.sns.arn
  protocol   = "http"
  endpoint   = "http://${module.ec2.dns_name}/sns"
  depends_on = [module.ec2]
}
