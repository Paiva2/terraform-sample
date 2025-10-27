# LB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "app-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

# Instances Key pair
resource "aws_key_pair" "key_pair_ec2" {
  key_name   = "ec2-key"
  public_key = file(var.key_pair_ec2_path)
}

# Instances roles
resource "aws_iam_role" "swarm_ec2_role" {
  name = "swarm-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role" "app_ec2_role" {
  name = "app-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Swarm Instance
resource "aws_iam_role_policy" "allow_access_to_swarm_manager" {
  name = "swarm-ec2-bucket-access"
  role = aws_iam_role.swarm_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = var.swarm_token_bucket_arn
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = "${var.swarm_token_bucket_arn}/*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "swarm_ec2_profile" {
  name = "swarm-ec2-profile"
  role = aws_iam_role.swarm_ec2_role.name
}

resource "aws_security_group" "allow-http_sg_ec2_swarm" {
  name        = "allow-http-swarm"
  description = "Allow incoming HTTP traffic to EC2 Swarm Manager Instance"
  vpc_id = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2377
    to_port     = 2377
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description      = "HTTP from VPC"
    from_port        = var.app_port
    to_port          = var.app_port
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "swarm_manager-ec2" {
  ami                    = var.instance_ami_id
  instance_type          = var.instance_type
  subnet_id              = var.instances_subnet_id
  vpc_security_group_ids = [aws_security_group.allow-http_sg_ec2_swarm.id]
  key_name               = aws_key_pair.key_pair_ec2.key_name
  iam_instance_profile   = aws_iam_instance_profile.swarm_ec2_profile.name
  count                  = 1

  user_data = templatefile("${path.module}/scripts/swarm_instance_user_data.sh", {
    AWS_REGION               = var.aws_region
    AWS_ACCESS_KEY_ID        = var.aws_access_key_id
    AWS_SECRET_ACCESS_KEY    = var.aws_secret_access_key
    APPLICATION_DOCKER_NAME  = var.application_docker_name
    APPLICATION_VERSION      = var.application_version
    SWARM_TOKEN_BUCKET       = var.swarm_token_bucket
    APPLICATION_PORT         = var.app_port
  })

  tags = {
    Name = "swarm-manager"
  }
}

# Application Instance
resource "aws_iam_role_policy" "allow_access_to_application_instance" {
  name = "app-app-ec2-bucket-access"
  role = aws_iam_role.app_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = var.swarm_token_bucket_arn
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = "${var.swarm_token_bucket_arn}/*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "app_ec2_profile" {
  name = "app-app-ec2-profile"
  role = aws_iam_role.app_ec2_role.name
}

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
    from_port        = var.app_port
    to_port          = var.app_port
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app-ec2" {
  ami                         = var.instance_ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.instances_subnet_id
  vpc_security_group_ids      = [aws_security_group.allow-http_sg_ec2.id]
  key_name                    = aws_key_pair.key_pair_ec2.key_name
  depends_on                  = [aws_instance.swarm_manager-ec2]
  iam_instance_profile        = aws_iam_instance_profile.app_ec2_profile.name
  count                       = 1

  user_data = templatefile("${path.module}/scripts/app_instance_user_data.sh", {
    SWARM_MANAGER_PRIVATE_IP = aws_instance.swarm_manager-ec2[count.index].private_ip
    SWARM_TOKEN_BUCKET       = var.swarm_token_bucket
  })

  tags = {
    Name = "application-ec2"
  }
}

# Target group attachment for LB
resource "aws_lb_target_group_attachment" "app_tg_lb_attachment" {
  for_each = merge(
    { for k, v in aws_instance.app-ec2 : "app-${k}" => v.id },
    { for k, v in aws_instance.swarm_manager-ec2 : "mgr-${k}" => v.id }
  )

  target_group_arn = var.app_lb_tg_arn
  target_id        = each.value
  port             = var.app_port
}