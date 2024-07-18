terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.57.0"
    }
  }
  backend "s3" {
    bucket = "neelareddy.stores"
    key = "expense-eks-ingress"
    region = "us-east-1"
    dynamodb_table = "neelareddy-dev"
  }
}

#provide authentication here
provider "aws" {
  region = "us-east-1"
}