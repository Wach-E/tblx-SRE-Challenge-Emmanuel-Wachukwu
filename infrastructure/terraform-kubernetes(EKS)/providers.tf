terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }

  backend "s3" {
    bucket         = "us-west-1-tblx-terraform-state-27062022"
    key            = "global/terraform.tfstate"
    region         = "us-west-1"
    encrypt        = true
    dynamodb_table = "tblx-locks-27062022"
  }

}

provider "aws" {
  region = var.region
}