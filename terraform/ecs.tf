resource "aws_ecs_cluster" "order_api" {
  name = "order-api-cluster"

  tags = {
    Name        = "order-api-cluster"
    Project     = "ecs-fargate-order-api"
    Environment = "dev"
  }
}

resource "aws_cloudwatch_log_group" "order_api" {
  name              = "/ecs/order-api"
  retention_in_days = 7

  tags = {
    Name        = "order-api-log-group"
    Project     = "ecs-fargate-order-api"
    Environment = "dev"
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "order-api-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "order-api-ecs-task-execution-role"
    Project     = "ecs-fargate-order-api"
    Environment = "dev"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "order_api" {
  family                   = "order-api-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "order-api-container"
      image     = "${aws_ecr_repository.order_api.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.order_api.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name        = "order-api-task-definition"
    Project     = "ecs-fargate-order-api"
    Environment = "dev"
  }
}

resource "aws_ecs_service" "order_api" {
  name            = "order-api-service"
  cluster         = aws_ecs_cluster.order_api.id
  task_definition = aws_ecs_task_definition.order_api.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets = [
      aws_subnet.public_1.id,
      aws_subnet.public_2.id
    ]

    security_groups = [
      aws_security_group.ecs_tasks.id
    ]

    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.order_api.arn
    container_name   = "order-api-container"
    container_port   = 5000
  }

  depends_on = [
    aws_lb_listener.http,
    aws_iam_role_policy_attachment.ecs_task_execution_role
  ]

  tags = {
    Name        = "order-api-service"
    Project     = "ecs-fargate-order-api"
    Environment = "dev"
  }
}