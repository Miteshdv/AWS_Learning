
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

# S3 module configuration.
module "s3" {
  source = "./modules/s3"
}

module "sqs" {
  source = "./modules/sqs"
  name   = "address-info-sqs-queue"
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
  sqs_queue_url       = module.sqs.url
}

# IAM module configuration, passing S3 bucket ARN and DynamoDB table ARN.
module "iam" {
  source             = "./modules/iam"
  s3_bucket_arn      = module.s3.bucket_arn
  dynamodb_table_arn = module.dynamodb.dynamodb_table_arn
  sqs_queue_arn      = module.sqs.arn
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
