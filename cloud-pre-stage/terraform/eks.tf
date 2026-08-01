# 1. Links your cluster tracking file safely to your existing S3 Bucket
terraform {
  backend "s3" {
    bucket         = "pyaephyo-terraform-state-bucket"
    key            = "eks-portfolio/terraform.tfstate"
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

# 3. Launches the Elastic Kubernetes Service core engine (Fully Operational v21.x Architecture)
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "aws-portfolio-cluster"
  kubernetes_version = "1.31"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # 🚀 ACCESS FIX 1: Switches cluster auth to the modern EKS API mode
  authentication_mode = "API"

  # 🚀 ACCESS FIX 2: Grants full cluster admin rights to your IAM roles automatically
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    worker_nodes = {
      min_size     = 3
      max_size     = 3
      desired_size = 3

      instance_types = ["t3.micro"]

      # 🚀 POLICY FIX: Attaches the core network policies required for the t3.micro nodes to register
      iam_role_additional_policies = {
        AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
        AmazonEKS_CNI_Policy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      }
    }
  }
}

