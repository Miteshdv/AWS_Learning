
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

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "availability-zone"
    values = ["us-west-2a"] # Replace with your desired availability zone
  }
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

# S3 module configuration.
module "s3" {
  source = "./modules/s3"
}


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

module "ec2" {
  source               = "./modules/ec2"
  ami                  = "ami-02868af3c3df4b3aa" # Replace with your desired AMI
  instance_type        = "t2.micro"
  key_name             = var.key_name
  instance_name        = "ExpressServer"
  iam_instance_profile = module.iam.instance_profile_name
  user_data = templatefile("server-user-data.sh.tpl", {
    sns_topic_arn       = module.sns.arn,
    aws_access_key      = var.aws_access_key,
    aws_secret_key      = var.aws_secret_key,
    s3_bucket_name      = module.s3.bucket_name,
    dynamodb_table_name = module.dynamodb.dynamodb_table_name,
    server_js_content   = file("${path.module}/server.js"),
    index_html_content  = file("${path.module}/index.html")
  })
  vpc_id                      = data.aws_vpc.default.id
  subnet_id                   = data.aws_subnet.default.id
  associate_public_ip_address = true
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

resource "aws_sns_topic_subscription" "http_subscription" {
  topic_arn  = module.sns.arn
  protocol   = "http"
  endpoint   = "http://${module.ec2.public_ip}:3001/sns"
  depends_on = [module.ec2]
}

