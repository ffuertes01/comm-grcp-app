
provider "aws" {
  region     = var.region

  default_tags {
    tags = {
      Project   = var.app_name
      Terraform = "True"
    }
  }
}

terraform {
  backend "s3" {
    bucket         = "comm-tf-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}

data "aws_secretsmanager_secret" "github_secret" {
  name = var.github_secret_name
}

data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = data.aws_secretsmanager_secret.github_secret.id
}

module "vpc" {
  source          = "./modules/network"
  cluster_name    = var.cluster_name 
  vpc_name        = var.vpc_name
  vpc_cidr        = var.vpc_cidr
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets                        
}


module "eks" {
  source              = "./modules/eks"
  app_name            = var.app_name
  cluster_name        = var.cluster_name 
  eks_instance_types  = var.eks_instance_types 
  eksnode_image       = var.eksnode_image 
  node_group_name     = var.node_group_name
  vpc_id              = module.vpc.vpc_id
  private_subnets     = module.vpc.private_subnets
  region              = var.region
  codebuild_role_arn  = module.cicd.codebuild_role_arn
}

module "cicd" {
  source = "./modules/cicd"
  region = var.region
  aws_account_id = var.aws_account_id
  app_name = var.app_name
  codebuild_image = var.codebuild_image
  ecr_repo_name = var.ecr_repo_name
  github_org = var.github_org
  cluster_name    = var.cluster_name
  repository_name = var.repository_name
  branch_name = var.branch_name
  codestar-connection = jsondecode(data.aws_secretsmanager_secret_version.github_token.secret_string)["CodestarConnection"]
  fullrepositoryid = "${var.github_org}/${var.repository_name}"
}