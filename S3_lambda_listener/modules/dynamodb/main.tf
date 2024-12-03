# This resource block defines an AWS DynamoDB table named "address_info_table".
# The table name is specified by the variable `dynamodb_table_name`.
# The billing mode is set to "PAY_PER_REQUEST", which means you only pay for the read and write requests you use.
# The `hash_key` is specified by the variable `hash_key`.
# The table has one attribute, which is the hash key, with its name and type specified by the variables `hash_key` and `hash_key_type` respectively.
# Tags are added to the table for identification and environment specification, using the variables `dynamodb_table_name` and `environment`.
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
