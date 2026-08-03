terraform {
  backend "s3" {
    bucket         = "pyaephyo-terraform-state-bucket"
    key            = "eks-portfolio/terraform.tfstate"
    region         = "us-east-1"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "portfolio-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  # 🚀 LESSON APPLIED: Opens the outbound routing tunnel so private nodes can handshake
  enable_nat_gateway = true
  single_nat_gateway = true
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "aws-portfolio-cluster"
  kubernetes_version = "1.31"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # 🚀 LESSON APPLIED: Activates modern API mode and auto-grants your user master admin rights
  authentication_mode                      = "API"
  enable_cluster_creator_admin_permissions = true

  # Keeps non-free observability logging agents turned off
  cluster_compute_config = {}

  eks_managed_node_groups = {
    worker_nodes = {
      min_size     = 3
      max_size     = 3
      desired_size = 3
      instance_types = ["t3.micro"]

      # Attaches core network policies so worker instances can securely log into the cluster
      iam_role_additional_policies = {
        AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
        AmazonEKS_CNI_Policy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      }
    }
  }
}

