provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  cluster_name     = "${var.project}-${var.environment}"
  state_bucket_arn = "arn:aws:s3:::${var.state_bucket_name}"
  lock_table_arn   = "arn:aws:dynamodb:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:table/${var.lock_table_name}"
}

module "vpc" {
  source = "../../modules/vpc"

  project      = var.project
  environment  = var.environment
  cluster_name = local.cluster_name
  vpc_cidr     = var.vpc_cidr
}

module "ecr" {
  source = "../../modules/ecr"

  repository_name = "otel-demo-ad"
  project         = var.project
  environment     = var.environment
}

module "eks" {
  source = "../../modules/eks"

  project                         = var.project
  environment                     = var.environment
  cluster_name                    = local.cluster_name
  cluster_version                 = var.cluster_version
  vpc_id                          = module.vpc.vpc_id
  private_subnet_ids              = module.vpc.private_subnet_ids
  public_subnet_ids               = module.vpc.public_subnet_ids
  public_access_cidrs             = var.cluster_endpoint_public_access_cidrs
  instance_types                  = var.node_instance_types
  desired_size                    = var.node_desired_size
  min_size                        = var.node_min_size
  max_size                        = var.node_max_size
  additional_admin_principal_arns = var.additional_admin_principal_arns
}

module "iam" {
  source = "../../modules/iam"

  project                     = var.project
  environment                 = var.environment
  github_owner                = var.github_owner
  github_repo                 = var.github_repo
  create_github_oidc_provider = var.create_github_oidc_provider
  ecr_repository_arn          = module.ecr.repository_arn
  state_bucket_arn            = local.state_bucket_arn
  lock_table_arn              = local.lock_table_arn
  eks_oidc_provider_arn       = module.eks.oidc_provider_arn
  eks_oidc_issuer_host        = module.eks.oidc_issuer_host
}

module "dns" {
  source = "../../modules/dns"

  project        = var.project
  environment    = var.environment
  hosted_zone_id = var.hosted_zone_id
  app_hostname   = var.app_hostname
  alb_dns_name   = var.alb_dns_name
  alb_zone_id    = var.alb_zone_id
}
