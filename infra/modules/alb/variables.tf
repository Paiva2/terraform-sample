variable "sg_lb_id" {
  type        = string
  description = "Security group ALB Id"
}

variable "alb_subnet_id_a" {
  type        = string
  description = "Subnet A for ALB Id"
}

variable "alb_subnet_id_b" {
  type        = string
  description = "Subnet b for ALB Id"
}

variable "app_target_group_arn" {
  type        = string
  description = "Application EC2 instances target group arn"
}