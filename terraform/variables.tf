variable "project_name" {
  description = "Project name"
  type        = string
  default     = "aws-web"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_a_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "public_subnet_b_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "private_subnet_a_cidr" {
  type    = string
  default = "10.0.11.0/24"
}

variable "private_subnet_b_cidr" {
  type    = string
  default = "10.0.12.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}

variable "secret_arn" {
  description = "ARN of the RDS database secret in AWS Secrets Manager"
  type        = string
  sensitive   = true
}