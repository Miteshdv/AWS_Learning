terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

# Security group for the ALB
resource "aws_security_group" "alb" {
  name        = "alb"
  description = "alb network traffic"
  vpc_id      = var.vpc_id

  # Ingress rule to allow HTTP traffic from anywhere
  ingress {
    description = "80 from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-ingress-sgr
  }

  # Egress rule to allow all outbound traffic to the EC2 instances
  egress {
    description     = "all all outbound traffic"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.ec2_instance_sg.id]
  }

  tags = {
    Name = "allow traffic"
  }
}

# Security group for the EC2 instances
resource "aws_security_group" "ec2_instance_sg" {
  name        = "ec2_instance_sg"
  description = "application network traffic"
  vpc_id      = var.vpc_id

  # Ingress rule to allow traffic on port 3001 from the ALB
  ingress {
    description = "3001 from alb"
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
  }

  # Egress rule to allow all outbound traffic
  egress {
    description = "all all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-ec2-no-public-egress-sgr
  }

  # Ingress rule to allow SSH access from anywhere
  ingress {
    description = "Allow SSH from EC2 Instance Connect"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # You can restrict this to specific IP ranges if needed
  }

  tags = {
    Name = "ec2_instance_sg"
  }
}

# Security group rule to allow traffic from the ALB to the EC2 instances on port 3001
resource "aws_security_group_rule" "alb_to_ec2" {
  type                     = "ingress"
  from_port                = 3001
  to_port                  = 3001
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ec2_instance_sg.id
}

