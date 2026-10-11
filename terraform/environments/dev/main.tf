terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
  }
}

provider "aws" {
  region = var.region
}

module "eks" {
  source = "../../modules/eks"

  cluster_name       = "gitops-demo"
  environment        = "dev"
  kubernetes_version = "1.30"
  region_hint        = var.region

  availability_zones   = ["${var.region}a", "${var.region}b"]
  vpc_cidr             = "10.10.0.0/16"
  private_subnet_cidrs = ["10.10.1.0/24", "10.10.2.0/24"]
  public_subnet_cidrs  = ["10.10.101.0/24", "10.10.102.0/24"]

  # Dev sizing: keep it small.
  node_instance_types = ["t3.small"]
  node_min_size       = 1
  node_desired_size   = 2
  node_max_size       = 3

  tags = {
    CostCenter = "learning"
  }
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "configure_kubectl" {
  value = module.eks.configure_kubectl
}
