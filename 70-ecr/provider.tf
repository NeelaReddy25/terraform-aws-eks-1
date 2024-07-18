terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.58.0"
    }
  }
  backend "s3" {
    bucket = "neelareddy.stores"
    key = "expense-aws-ecr"
    region = "us-east-1"
    dynamodb_table = "neelareddy-dev"
  }
}

#provide autentication here
provider "aws" {
  region = "us-east-1"
}