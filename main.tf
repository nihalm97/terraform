# resource "aws_s3_bucket" "example" {
#   bucket = "nihals-first-freekin-bucket-12397"

#   tags = {
#     Name        = "My bucket"
#     Environment = "Dev"
#   }
# }

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
}