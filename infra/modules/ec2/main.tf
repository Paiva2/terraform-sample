resource "aws_security_group" "allow-http_sg_ec2" {
  name        = "allow-http"
  description = "Allow incoming HTTP traffic to EC2 (tf-app) Instance"
  vpc_id = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP from VPC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "key_pair_ec2" {
  key_name   = "ec2-key"
  public_key = file(var.key_pair_ec2_path)
}

resource "aws_instance" "tf-ec2" {
  ami                         = "ami-0199d4b5b8b4fde0e"
  instance_type               = "t3.micro"
  subnet_id                   = var.subnet_id
  security_groups             = [aws_security_group.allow-http_sg_ec2.id]
  key_name                    = aws_key_pair.key_pair_ec2.key_name

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y docker
    systemctl enable docker
    systemctl start docker
    usermod -aG docker ec2-user

    cat <<EOT > /home/ec2-user/.env
      AWS_REGION=${var.aws_region}
      AWS_ACCESS_KEY_ID=${var.aws_access_key_id}
      AWS_SECRET_ACCESS_KEY=${var.aws_secret_access_key}
      SPRING_PROFILES_ACTIVE=staging
    EOT

    docker pull ${var.application_docker_name}:${var.application_version}
    docker run --env-file /home/ec2-user/.env --name tf-deploy-app -p 8080:8080 ${var.application_docker_name}:${var.application_version}
  EOF
}