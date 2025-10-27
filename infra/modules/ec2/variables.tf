variable "instance_ami_id" {
  description = "Instance AMI"
  type        = string
  default     = "ami-0199d4b5b8b4fde0e"
}

variable "instance_type" {
  description = "Instance Type"
  type        = string
  default     = "t3.micro"
}

variable "vpc_id" {
  description = "VPC Id"
  type        = string
}

variable "instances_subnet_id" {
  description = "Subnet Id"
  type        = string
}

variable key_pair_ec2_path {
  description = "Key par used to SSH into EC2"
  type        = string
}

variable "application_docker_name" {
  description = "Name of application to use while pulling from dockerhub"
  default = "paiva2/app-java"
  type = string
}

variable "application_version" {
  description = "Version of application to use while pulling from dockerhub"
  default = "2.0"
  type = string
}

variable "aws_region" {
  type        = string
  description = "Região AWS onde os recursos serão criados"
}

variable "aws_access_key_id" {
  type        = string
  description = "AWS Access Key ID"
  sensitive   = true
}

variable "aws_secret_access_key" {
  type        = string
  description = "AWS Secret Access Key"
  sensitive   = true
}

variable "swarm_token_bucket_arn" {
  type        = string
  description = "ARN from Swarm Token Bucket on S3"
}

variable "swarm_token_bucket" {
  type        = string
  description = "Swarm Token Bucket name on S3"
}

variable "app_port" {
  type        = number
  description = "Application exposed port"
}

variable "app_lb_tg_arn" {
  type        = string
  description = "Application Target group ARN used for LB"
}