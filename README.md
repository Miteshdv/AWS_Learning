# AWS Infrastructure Setup with Terraform

This project sets up the necessary AWS resources using Terraform. The resources include VPC, subnets, security groups, S3 bucket, SNS topic, DynamoDB table, Lambda function, IAM roles and policies, EC2 instances, and an Application Load Balancer (ALB).

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed
- AWS credentials configured (access key and secret key)

## Instructions

### 1. Terraform Initialization
Add a file named `terraform.tfvars` with the following content:

```plaintext
availability_zones    = ["us-west-2a", "us-west-2b"]
cidr_block            = "10.0.0.0/16"
bastion_instance_type = "t3.micro"
app_instance_type     = "t3.micro"
db_instance_type      = "t3.micro"
key_name              = "YOUR KEY PAIR NAME"
aws_access_key        = "YOUR ACCESS KEY"
aws_secret_key        = "YOUR SECRET KEY"
```
Initialize the Terraform configuration by running the following command:

```sh
terraform init

To Apply 

terraform apply

```
### Architecure Diagram
Simplified Diagram
<img alt="Brainboard - AWS" src="./Brainboard - AWS Learning Simple.png">

This diagram represents the AWS architecture set up by this Terraform configuration.
<img alt="Brainboard - AWS" src="./Brainboard - AWS Board.png">




### Outputs
After applying the Terraform configuration, you will get the following outputs:

VPC ID
Public Subnet A ID
Public Subnet B ID
Private Subnet A ID
Private Subnet B ID
ALB DNS Name
These outputs can be used to verify the created resources and access the Application Load Balancer.

### Cleanup
To destroy the created resources, run the following command:

``` sh
terraform destroy
```