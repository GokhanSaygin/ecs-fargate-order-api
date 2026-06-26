resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]

  tags = {
    Name        = "github-actions-oidc-provider"
    Project     = "ecs-fargate-order-api"
    Environment = "dev"
  }
}

resource "aws_iam_role" "github_actions_deploy_role" {
  name = "ecs-fargate-order-api-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:GokhanSaygin/ecs-fargate-order-api:*"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "ecs-fargate-order-api-github-actions-role"
    Project     = "ecs-fargate-order-api"
    Environment = "dev"
  }
}

resource "aws_iam_policy" "github_actions_deploy_policy" {
  name        = "ecs-fargate-order-api-github-actions-policy"
  description = "Permissions for GitHub Actions to build, push Docker images to ECR, and deploy ECS service"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:BatchGetImage",
          "ecr:DescribeRepositories"
        ]
        Resource = aws_ecr_repository.order_api.arn
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = aws_iam_role.ecs_task_execution_role.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_deploy_attach" {
  role       = aws_iam_role.github_actions_deploy_role.name
  policy_arn = aws_iam_policy.github_actions_deploy_policy.arn
}