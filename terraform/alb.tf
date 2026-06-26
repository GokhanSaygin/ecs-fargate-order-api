resource "aws_lb" "order_api" {
  name               = "order-api-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  tags = {
    Name        = "order-api-alb"
    Project     = "ecs-fargate-order-api"
    Environment = "dev"
  }
}

resource "aws_lb_target_group" "order_api" {
  name        = "order-api-target-group"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name        = "order-api-target-group"
    Project     = "ecs-fargate-order-api"
    Environment = "dev"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.order_api.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.order_api.arn
  }
}