output "github_actions_role_arn" {
  description = "IAM role ARN used by GitHub Actions OIDC"
  value       = aws_iam_role.github_actions_deploy_role.arn
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.order_api.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.order_api.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.order_api.name
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.order_api.dns_name
}