# Available Availability Zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

# Main VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "order-api-vpc"
    Project     = "ecs-fargate-order-api"
    Environment = "dev"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "order-api-igw"
    Project     = "ecs-fargate-order-api"
    Environment = "dev"
  }
}

# Public subnet in the first Availability Zone
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "order-api-public-subnet-1"
    Project     = "ecs-fargate-order-api"
    Environment = "dev"
  }
}

# Public subnet in the second Availability Zone
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name        = "order-api-public-subnet-2"
    Project     = "ecs-fargate-order-api"
    Environment = "dev"
  }
}

# Route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "order-api-public-route-table"
    Project     = "ecs-fargate-order-api"
    Environment = "dev"
  }
}

# Connect first public subnet to route table
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

# Connect second public subnet to route table
resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# Security group for Application Load Balancer
resource "aws_security_group" "alb" {
  name        = "order-api-alb-sg"
  description = "Allow HTTP traffic to the Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "order-api-alb-sg"
    Project     = "ecs-fargate-order-api"
    Environment = "dev"
  }
}

# Security group for ECS Fargate tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "order-api-ecs-tasks-sg"
  description = "Allow traffic from the ALB to ECS tasks"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow Flask traffic only from the ALB"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "order-api-ecs-tasks-sg"
    Project     = "ecs-fargate-order-api"
    Environment = "dev"
  }
}