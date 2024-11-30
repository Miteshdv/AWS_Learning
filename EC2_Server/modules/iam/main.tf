resource "aws_iam_role" "ec2_instance_connect" {
  name = "EC2InstanceConnectRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_instance_connect_policy" {
  role       = aws_iam_role.ec2_instance_connect.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_instance_profile" "ec2_instance_connect" {
  name = "EC2InstanceConnectProfile"
  role = aws_iam_role.ec2_instance_connect.name
}

