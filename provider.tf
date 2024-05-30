provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "mk-1-tk-1nh"  # Hardcoded bucket name
    key    = "terraform/files/terraform.tfstate"
    region = "ap-south-1"  # Hardcoded region
    encrypt = true
  }
}
