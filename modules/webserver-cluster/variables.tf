variable "app_port" {
  description = "Port that the FLask app listens on inside the container"
  type = number
  default = 5000
}

variable "image_tag" {
  description = "Tag of the Docker image to pull from ECR"
  type = string
  default = "latest"
}

variable "instance_type" {
  description = "EC2 instance type for the webserver cluster"
  type = string
  default = "t3.micro"
}

variable "ecr_repo_name" {
  description = "Name of the ECR repository that stores the Divot backend image"
  type = string
  default = "divot-backend"
}

variable "environment" {
  description = "Environment name (dev, stage, prod, etc.)"
  type = string
  default = "prod"
}

