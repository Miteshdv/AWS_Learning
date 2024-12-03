terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

resource "aws_security_group" "alb" {
  name        = "alb"
  description = "alb network traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "80 from anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-ingress-sgr
  }

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

resource "aws_security_group" "ec2_instance_sg" {
  name        = "ec2_instance_sg"
  description = "application network traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "80 from alb"
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
  }

  egress {
    description = "all all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-ec2-no-public-egress-sgr
  }

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

resource "aws_security_group_rule" "alb_to_ec2" {
  type                     = "ingress"
  from_port                = 3001
  to_port                  = 3001
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ec2_instance_sg.id
}

# resource "aws_security_group" "ec2_instance_sg" {
#   name        = "ec2_instance_sg"
#   description = "Allow inbound SSH traffic from EC2 Instance Connect"
#   vpc_id      = var.vpc_id
#
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   ingress {
#     from_port   = 3001
#     to_port     = 3001
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   ingress {
#     description = "Allow SSH from EC2 Instance Connect"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # You can restrict this to specific IP ranges if needed
#   }
#
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   tags = {
#     Name = "ec2_instance_sg"
#   }
# }

