# 1. Links your cluster tracking file safely to your existing S3 Bucket
terraform {
  backend "s3" {
    bucket         = "pyaephyo-terraform-state-bucket"
    key            = "eks-portfolio/terraform.tfstate" # Your clean, isolated path
    region         = "us-east-1"
  }
}

# 2. Creates your clean VPC cluster network infrastructure
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "portfolio-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

# 3. Launches the Elastic Kubernetes Service core engine
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "aws-portfolio-cluster"
  cluster_version = "1.30"

  cluster_endpoint_public_access = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  # FIXED: Scaled to 3 nodes to increase combined pod limits to 12 total pods!
  eks_managed_node_groups = {
    worker_nodes = {
      min_size     = 3
      max_size     = 3
      desired_size = 3

      instance_types = ["t3.micro"]
    }
  }
}

