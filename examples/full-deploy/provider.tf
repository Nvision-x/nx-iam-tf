terraform {

  # backend "s3" {
  #   bucket         = "your-s3-bucket-name"            # <-- create this bucket first
  #   key            = "path/to/your/terraform.tfstate" # <-- like "envs/dev/terraform.tfstate"
  #   region         = "us-east-1"                      # <-- S3 bucket region
  #   dynamodb_table = "your-dynamodb-lock-table"       # <-- create this table first
  #   encrypt        = true
  # }

  # aws s3api create-bucket --bucket your-s3-bucket-name --region us-east-1

  # aws dynamodb create-table \
  #   --table-name your-dynamodb-lock-table \
  #   --attribute-definitions AttributeName=LockID,AttributeType=S \
  #   --key-schema AttributeName=LockID,KeyType=HASH \
  #   --billing-mode PAY_PER_REQUEST \
  #   --region us-east-1

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.region
}


