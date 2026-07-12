terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configures AWS to deploy everything into the standard US East region
provider "aws" {
  region = "us-east-1"
}

