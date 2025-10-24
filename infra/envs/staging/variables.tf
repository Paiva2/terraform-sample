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