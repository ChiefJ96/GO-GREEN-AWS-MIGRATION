// modules/alb/main.tf

resource "aws_lb" "gogreen_alb" {
  name               = "gogreen-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [
    var.public_subnet_a,
    var.public_subnet_b
  ]
  security_groups    = [var.alb_sg]

  tags = {
    Name = "GoGreenALB"
  }
}

resource "aws_lb_target_group" "web_tg" {
  name     = "gogreen-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "WebTargetGroup"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.gogreen_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}
resource "aws_lb_target_group" "this" {
  name     = var.target_group_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id  # This must also be defined in variables.tf

  health_check {
    path                = var.health_check_path
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}
