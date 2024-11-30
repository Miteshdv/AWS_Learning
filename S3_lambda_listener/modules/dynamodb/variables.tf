variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  type        = string
}


variable "hash_key" {
  description = "The hash key for the DynamoDB table"
  type        = string
}

variable "hash_key_type" {
  description = "The type of the hash key (S for string, N for number, B for binary)"
  type        = string
}

variable "environment" {
  description = "The environment (e.g., Dev, Prod)"
  type        = string
}
