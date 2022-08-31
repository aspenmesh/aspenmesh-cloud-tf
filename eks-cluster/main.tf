provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  config_path            = var.kubernetes_config_path

  exec {
    api_version = "client.authentication.k8s.io/v1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    config_path            = var.kubernetes_config_path

    exec {
      api_version = "client.authentication.k8s.io/v1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
    }
  }
}

data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

locals {
  vpc_name = join("-", [var.cluster_name, "vpc"])
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.vpc_name
  cidr = var.vpc_cidr
  azs  = local.azs

  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true
  single_nat_gateway   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.29.0"

  cluster_name                = var.cluster_name
  vpc_id                      = module.vpc.vpc_id
  subnet_ids                  = module.vpc.private_subnets
  cluster_version             = var.eks_cluster_version
  create_cloudwatch_log_group = var.create_cloudwatch_log_group

  eks_managed_node_groups = {
    node_group = {
      node_group_name = "managed-nodegroup"
      instance_types  = [var.ng_instance_types]
      desired_size    = var.ng_desired_size
      max_size        = var.ng_max_size
      subnet_ids      = module.vpc.private_subnets
    }
  }

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::${var.aws_account_id}:role/eks-admin"
      username = "cluster-admin"
      groups   = ["system:masters"]
    }
  ]

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::${var.aws_account_id}:user/aspenmesh_circleci_automation_programmatic_access"
      username = "cluster-admin"
      groups   = ["system:masters"]
    }
  ]

}

module "iam_eks_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.3.1"

  create_role       = true
  role_name         = "${var.cluster_name}-secrets-manager"
  role_requires_mfa = false

  trusted_role_arns       = ["arn:aws:iam::${var.aws_account_id}:root"]
  custom_role_policy_arns = ["arn:aws:iam::${var.aws_account_id}:policy/aspenmesh-cloud-secret-reader"]
}


