output "tf_ec2_data_id" {
  value = aws_ebs_volume.ebs-app-ec2.id
}

output "manager_ec2_data_id" {
  value = aws_ebs_volume.ebs_ec2_swarm_manager.id
}