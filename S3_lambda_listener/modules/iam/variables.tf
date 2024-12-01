variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table"
  type        = string
}


variable "sns_topic_arn" {
  description = "The ARN of the SNS topic"
  type        = string
}
