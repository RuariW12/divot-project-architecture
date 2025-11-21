data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_vpc" "default" {
    default = true
}

data "aws_subnets" "default" {
    filter {
      name = "vpc-id"
      values = [data.aws_vpc.default.id]
    }
}

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

# ECR Repository

resource "aws_ecr_repository" "divot_backend" {
  name = var.ecr_repo_name

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# IAM role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "divot-ec2-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# ECR read-only permissions
resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


# EC2 instance profile wrapper
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "divot-ec2-instance-profile-${var.environment}"
  role = aws_iam_role.ec2_role.name
}


# Security groups

resource "aws_security_group" "webserver_sg" {
  name = "divot-webserver-sg-${var.environment}"
  description = "Security group for the Divot webserver"
  vpc_id = data.aws_vpc.default.id

  # HTTP from anywhere for now
  ingress = {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "divot-webserver-sg-${var.environment}"
  }
}

# Single EC2 instance pulling from ECr and running Docker container

resource "aws_instance" "webserver" {
  ami = data.aws_ssm_parameter.al2023.value
  instance_type = var.instance_type

  # For now using default public subnet
  subnet_id = data.aws_subnets.default.ids[0]

  vpc_security_group_ids = [aws_security_group.webserver_sg.id]

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

   user_data = <<-EOF
    #!/bin/bash
    set -xe

    REGION="${data.aws_region.current.name}"
    IMAGE_URI="${aws_ecr_repository.divot_backend.repository_url}:${var.image_tag}"
    APP_PORT="${var.app_port}"

    yum update -y
    yum install -y docker

    systemctl enable docker
    systemctl start docker

    # Extract just the registry host from the ECR repo URL
    REGISTRY_HOST="$(echo "${aws_ecr_repository.divot_backend.repository_url}" | cut -d'/' -f1)"

    # Login to ECR using the instance role
    aws ecr get-login-password --region $REGION \
      | docker login --username AWS --password-stdin $REGISTRY_HOST

    # Pull the image
    docker pull $IMAGE_URI

    # Run the container
    # Map host port 80 -> container port APP_PORT (5000)
    docker run -d --name divot-backend -p 80:${var.app_port} $IMAGE_URI
  EOF

  tags = {
    Name = "divot-webserver-${var.environment}"
  }
}


