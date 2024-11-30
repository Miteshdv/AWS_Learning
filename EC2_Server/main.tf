terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

# AWS provider configuration with region and credentials.
provider "aws" {
  region     = "us-west-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

data "terraform_remote_state" "sqs" {
  backend = "local"
  config = {
    path = "../S3_Lambda_Listener/terraform.tfstate" # Path to the local state file
  }
}

data "aws_vpc" "default" {
  default = true
}


module "iam" {
  source = "./modules/iam"
}

module "ec2" {
  source               = "./modules/ec2"
  ami                  = "ami-02868af3c3df4b3aa" # Replace with your desired AMI
  instance_type        = "t2.micro"
  key_name             = var.key_name
  instance_name        = "ExpressServer"
  iam_instance_profile = module.iam.instance_profile_name
  user_data = templatefile("server-user-data.sh.tpl", {
    sqs_url           = data.terraform_remote_state.sqs.outputs.sqs_url,
    aws_access_key    = var.aws_access_key,
    aws_secret_key    = var.aws_secret_key
    server_js_content = file("${path.module}/server.js")
  })
  vpc_id = data.aws_vpc.default.id
}
