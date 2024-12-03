output "bucket_name" {
  value = module.s3.bucket_name
}

output "dynamodb_table_name" {
  value = module.dynamodb.dynamodb_table_name
}

output "sns_urn" {
  value = module.sns.arn
}


output "alb_dns_name" {
  value = module.ec2.dns_name
}


