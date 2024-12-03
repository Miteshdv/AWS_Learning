output "application_sg_id" {
  description = "web server sg id"
  value       = aws_security_group.ec2_instance_sg.id
}

output "alb_sg_id" {
  description = "alb sg id"
  value       = aws_security_group.alb.id
}


