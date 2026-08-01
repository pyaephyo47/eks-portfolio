terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # 🚀 SYNCHRONIZED: Matches your exact registry research criteria!
      version = ">= 6.52.0"
    }
  }
}

# Configures AWS to deploy everything into the standard US East region
provider "aws" {
  region = "us-east-1"
}

