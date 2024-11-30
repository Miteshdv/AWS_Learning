output "bucket_name" {
  value = module.s3.bucket_name
}

output "sqs_url" {
  value = module.sqs.url
}
