output "vpc_id_ec2" {
  value = aws_vpc.tf-app_vpc_ec2.id
}

output "public_subnet_id_ec2" {
  value = aws_subnet.public_subnet_ec2.id
}
