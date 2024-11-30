resource "aws_security_group" "ec2_instance_sg" {
  name        = "ec2_instance_sg"
  description = "Allow inbound SSH traffic from EC2 Instance Connect"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH from EC2 Instance Connect"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # You can restrict this to specific IP ranges if needed
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2_instance_sg"
  }
}

resource "aws_instance" "express_server" {
  ami                  = var.ami
  instance_type        = var.instance_type
  key_name             = var.key_name
  iam_instance_profile = var.iam_instance_profile
  user_data            = var.user_data

  tags = {
    Name = var.instance_name
  }
}
