#############################
#  Application Load Balancer
#############################


resource "aws_lb" "app_lb" {
  name               = "much-to-do-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnets
  security_groups    = [var.alb_sg]
}

#############################
# Target Group
#############################

resource "aws_lb_target_group" "app_tg" {
  name        = "much-to-do-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2

  }

}


####################################
# Listener
####################################

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
