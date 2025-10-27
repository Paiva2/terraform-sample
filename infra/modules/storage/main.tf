resource "aws_ebs_volume" "ebs-app-ec2" {
  size              = 10
  availability_zone = var.ec2_instance_az
  type              = "gp3"

  tags = {
    Name = "tf-ec2-data"
  }
}

resource "aws_ebs_volume" "ebs_ec2_swarm_manager" {
  size              = 10
  availability_zone = var.ec2_instance_az
  type              = "gp3"

  tags = {
    Name = "manager-ec2-data"
  }
}

resource "aws_volume_attachment" "data_attachment_app" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.ebs-app-ec2.id
  instance_id = var.ec2_instance_id
}

resource "aws_volume_attachment" "data_attachment_swarm_manager" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.ebs_ec2_swarm_manager.id
  instance_id = var.swarm_manager_instance_id
}