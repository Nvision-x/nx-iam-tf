terraform {

  # backend "s3" {
  #   bucket         = "tfstate-staging-nx"            # <-- create this bucket first
  #   key            = "tfstate/iam/terraform.tfstate" # <-- like "envs/dev/terraform.tfstate"
  #   region         = "us-east-1"                     # <-- S3 bucket region
  #   dynamodb_table = "tflocks-staging-nx"            # <-- create this table first
  #   encrypt        = true
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.5.7"
}

provider "aws" {

}


