output "application_instance_arn" {
  value = aws_instance.app-ec2[0].arn
}

output "swarm_instance_arn" {
  value = aws_instance.swarm_manager-ec2[0].arn
}

output "ec2_instance_az" {
  value = aws_instance.app-ec2[0].availability_zone
}

output "ec2_manager_sg_id" {
  value = aws_instance.swarm_manager-ec2[0].id
}

output "lb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "ec2_sg_id" {
  value = aws_instance.app-ec2[0].id
}

output "app_ec2_instance_id" {
  value = aws_instance.app-ec2[0].id
}

output "manager_ec2_instance_id" {
  value = aws_instance.swarm_manager-ec2[0].id
}