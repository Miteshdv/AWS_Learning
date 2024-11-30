output "arn" {
  description = "The ARN of the SQS queue"
  value       = aws_sqs_queue.this.arn
}

output "url" {
  value = aws_sqs_queue.this.url
}


