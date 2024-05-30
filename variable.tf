variable "region" {
  description = "The AWS region to deploy to"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "The name of the SSH key pair"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "subnet_cidr_a" {
  description = "The CIDR block for subnet A"
  type        = string
}

variable "subnet_cidr_b" {
  description = "The CIDR block for subnet B"
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "backend_region" {
  description = "The AWS region for the Terraform backend"
  type        = string
}
