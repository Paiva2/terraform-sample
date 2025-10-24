variable "vpc_id" {
  description = "VPC Id"
  type        = string
}

variable "subnet_id" {
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
  default = "latest"
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