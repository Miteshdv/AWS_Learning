#!/bin/bash

# Zip the Lambda function
zip -r lambda_function_payload.zip lambda_function.py

# Initialize Terraform
terraform init

# Apply the Terraform configuration
terraform apply -auto-approve