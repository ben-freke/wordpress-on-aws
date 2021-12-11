provider "aws" {
  region = var.region
}

terraform {
  required_version = ">= 1.0.6"
  required_providers {
    mysql = {
      source  = "petoju/mysql"
      version = "3.0.6"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    encrypt = true
  }
}