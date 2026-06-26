resource "aws_ecr_repository" "order_api" {
  name                 = "ecs-fargate-order-api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "ecs-fargate-order-api"
    Project     = "ecs-fargate-order-api"
    Environment = "dev"
  }
}