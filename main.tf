provider "aws" {
  region = "eu-north-1"
}

# Lambda function
resource "aws_lambda_function" "my_lambda" {
  filename         = "lambda_function.zip"
  function_name    = "my_lambda_function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("lambda_function.zip")
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach IAM Policy to Lambda Role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count      = 2
  subnet_id  = element(aws_subnet.subnet[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

# ALB
resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.subnet[*].id
}

# ALB Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lambda_tg.arn
  }
}

# Target Group for Lambda
resource "aws_lb_target_group" "lambda_tg" {
  name        = "lambda-tg"
  target_type = "lambda"
  vpc_id      = aws_vpc.main.id

  health_check {
    enabled             = true
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

# Attach Lambda to Target Group
resource "aws_lb_target_group_attachment" "lambda_attachment" {
  target_group_arn = aws_lb_target_group.lambda_tg.arn
  target_id        = aws_lambda_function.my_lambda.arn
}

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow http traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Subnet
resource "aws_subnet" "subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone       = element(["eu-north-1a", "eu-north-1b"], count.index)
  map_public_ip_on_launch = true
}

# Upload Lambda function package
resource "null_resource" "package_lambda" {
  provisioner "local-exec" {
    command = "zip lambda_function.zip lambda_function.py"
  }

  triggers = {
    source = filesha256("lambda_function.py")
  }
}

data "aws_iam_policy_document" "alb_invoke_lambda" {
  statement {
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.my_lambda.arn]
    principals {
      type        = "Service"
      identifiers = ["elasticloadbalancing.amazonaws.com"]
    }
  }
}

resource "aws_lambda_permission" "allow_alb" {
  statement_id  = "AllowExecutionFromALB"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.lambda_tg.arn
}
