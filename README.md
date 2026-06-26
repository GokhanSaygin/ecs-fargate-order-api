# ECS Fargate Order API

A containerized Order API deployed on AWS ECS Fargate using Docker, Amazon ECR, Application Load Balancer, CloudWatch, Terraform, and GitHub Actions CI/CD.

## Project Overview

This project demonstrates how to deploy a containerized microservice on AWS using a production-style cloud workflow.

I built a simple Order API with Python Flask, packaged it as a Docker container, pushed the image to Amazon ECR, and deployed it to Amazon ECS Fargate behind an Application Load Balancer.

The infrastructure is managed with Terraform, and the deployment process is automated using GitHub Actions with OIDC authentication.

## Architecture

```text
User
↓
Application Load Balancer
↓
ECS Fargate Service
↓
Docker Container
↓
Python Flask Order API
↓
CloudWatch Logs
```

CI/CD workflow:

```text
GitHub Push
↓
GitHub Actions
↓
OIDC Authentication to AWS
↓
Build Docker Image
↓
Push Image to Amazon ECR
↓
Update ECS Fargate Service
```

## AWS Services Used

* Amazon ECS Fargate
* Amazon ECR
* Application Load Balancer
* Amazon VPC
* Public Subnets
* Internet Gateway
* Security Groups
* IAM Roles and Policies
* CloudWatch Logs
* Terraform
* GitHub Actions
* GitHub OIDC

## Application Endpoints

The API includes the following endpoints:

```text
/          - Home endpoint
/health    - Health check endpoint
/orders    - Returns all sample orders
/orders/1  - Returns a specific order by ID
```

Example response from `/health`:

```json
{
  "status": "healthy"
}
```

## Why I Built This Project

The goal of this project was to demonstrate containerized application deployment on AWS.

In my previous project, I used serverless services such as Lambda, API Gateway, S3, CloudFront, and Amazon Bedrock. With this project, I wanted to show that I can also deploy and manage container-based workloads using ECS Fargate.

This project is useful for Cloud Engineer, DevOps Engineer, and Cloud Infrastructure Engineer roles because it includes Docker, ECR, ECS Fargate, Load Balancing, Terraform, IAM, CloudWatch, and CI/CD.

## Real-World Use Case

This architecture can be used for microservices in real-world applications.

For example, an e-commerce company may have separate services such as:

* Order Service
* Payment Service
* Inventory Service
* User Service
* Notification Service

This project represents a simple Order Service. The service runs inside a Docker container on ECS Fargate, receives traffic through an Application Load Balancer, and can be updated automatically through a CI/CD pipeline.

## Terraform Infrastructure

Terraform is used to create and manage the AWS infrastructure, including:

* VPC
* Public subnets
* Internet Gateway
* Route tables
* Security groups
* ECR repository
* ECS cluster
* ECS task definition
* ECS service
* Application Load Balancer
* Target group
* Listener
* CloudWatch log group
* IAM roles and policies
* GitHub Actions OIDC role

## GitHub Actions CI/CD

GitHub Actions is used to automate deployment.

When code is pushed to the `main` branch, the workflow:

1. Checks out the source code
2. Authenticates to AWS using OIDC
3. Builds the Docker image for `linux/amd64`
4. Pushes the image to Amazon ECR
5. Forces a new ECS deployment

I used OIDC instead of long-term AWS access keys. This allows GitHub Actions to assume an IAM role in AWS using temporary credentials, which is more secure than storing AWS access keys in GitHub Secrets.

## Troubleshooting Example

During deployment, the ECS task initially failed even though the Docker image worked locally.

I checked ECS service events and CloudWatch Logs. The logs showed:

```text
exec /usr/local/bin/python: exec format error
```

The root cause was an image architecture mismatch. The image was built on an Apple Silicon Mac as ARM64, but ECS Fargate was expecting AMD64.

I fixed the issue by rebuilding and pushing the Docker image with the correct platform:

```bash
docker buildx build \
  --platform linux/amd64 \
  -t <account-id>.dkr.ecr.us-east-1.amazonaws.com/ecs-fargate-order-api:latest \
  --push .
```

After forcing a new ECS deployment, the service became healthy behind the Application Load Balancer.

## Technologies Used

* Python
* Flask
* Docker
* AWS ECS Fargate
* AWS ECR
* AWS ALB
* AWS CloudWatch
* AWS IAM
* Terraform
* GitHub Actions
* OIDC
* AWS CLI

## Local Development

Build the Docker image locally:

```bash
docker build -t ecs-fargate-order-api .
```

Run the container locally:

```bash
docker run -p 5001:5000 ecs-fargate-order-api
```

Test the API:

```bash
curl http://localhost:5001/health
curl http://localhost:5001/orders
```

## Deployment

The application is deployed automatically through GitHub Actions when changes are pushed to the `main` branch.

Manual ECS redeployment can be triggered with:

```bash
aws ecs update-service \
  --cluster order-api-cluster \
  --service order-api-service \
  --force-new-deployment \
  --region us-east-1
```

## What I Learned

Through this project, I practiced:

* Building a Flask API
* Creating a Dockerfile
* Running and testing containers locally
* Pushing Docker images to Amazon ECR
* Deploying containers on ECS Fargate
* Configuring an Application Load Balancer
* Using CloudWatch Logs for troubleshooting
* Writing infrastructure as code with Terraform
* Using GitHub Actions for CI/CD
* Using OIDC for secure AWS authentication
* Debugging container architecture issues

## Author

Ahmet Gokhan Saygin
Cloud Infrastructure Engineer
GitHub: GokhanSaygin
