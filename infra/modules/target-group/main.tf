resource "aws_lb_target_group" "app_target_group" {
  name     = "app-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  #todo
  health_check {
    path                = "/status-check"
    protocol            = "HTTP"
    matcher             = "200-499"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }
}