output "lambda_exec_role_arn" {
  value = aws_iam_role.lambda_exec_role.arn
}
output "instance_profile_name" {
  value = aws_iam_instance_profile.ec2_instance_connect.name
}


