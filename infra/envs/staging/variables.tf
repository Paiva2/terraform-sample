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

variable "key_pair_path" {
  type        = string
  description = "Key pair to use on SSH"
  sensitive   = true
}

variable "app_port" {
  type        = number
  description = "HTTP port used by application"
  sensitive   = false
}