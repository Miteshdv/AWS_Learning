resource "aws_dynamodb_table" "address_info_table" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.hash_key

  attribute {
    name = var.hash_key
    type = var.hash_key_type
  }

  tags = {
    Name        = var.dynamodb_table_name
    Environment = var.environment
  }
}
