terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

resource "aws_lambda_function" "address-info_lambda" {
  function_name    = "address-info_lambda"
  role             = var.iam_role_arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  filename         = "lambda_function_payload.zip"
  source_code_hash = filebase64sha256("lambda_function_payload.zip")

  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_table_name
      SQS_QUEUE_URL  = var.sqs_queue_url
    }
  }
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.address-info_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket_arn
}
