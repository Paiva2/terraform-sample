resource "aws_lb" "app_load_balancer" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_lb_id]
  subnets            = [var.alb_subnet_id_a, var.alb_subnet_id_b]

  enable_deletion_protection = false

  tags = {
    Environment = "staging"
  }
}

resource "aws_lb_listener" "lb_server_listener" {
  load_balancer_arn = aws_lb.app_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = var.app_target_group_arn
  }
}