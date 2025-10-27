output "vpc_id_ec2" {
  value = aws_vpc.app_vpc.id
}

output "public_subnet_id_ec2" {
  value = aws_subnet.public_subnet_ec2_app.id
}

output "public_subnet_alb_a_id" {
  value = aws_subnet.public_subnet_alb_a.id
}

output "public_subnet_alb_b_id" {
  value = aws_subnet.public_subnet_alb_b.id
}