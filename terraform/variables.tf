variable "region" {
  type        = string
  default     = "us-east-1"   
}

variable "cluster_name" {
  type        = string
  default     = "comm-cluster"   
}

variable "vpc_name" {
  type        = string
  default     = "comm-vpc"   
}

variable "vpc_cidr" {
  type        = string
  default     = "10.10.0.0/16"   
}

variable "private_subnets" {
  type        = list
  default     = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]   
}

variable "public_subnets" {
  type        = list
  default     = ["10.10.4.0/24", "10.10.5.0/24", "10.10.6.0/24"]   
}

variable "node_group_name" {
  type     = string
  default  = "node-group-1"
}

variable "eks_instance_types" {
  type = list
  default = ["t3.small"]
}

variable "eksnode_image" {
  type = string
  default = "602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller"
}

variable "app_name" {
  type        = string
  default     = "comm"   
}

variable "codebuild_image" {
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"   
}

variable "github_org" {
  type        = string
  default     = "ffuertes01"
}

variable "repository_name" {
  type        = string
  default     = "comm-grcp-app"
}

variable "branch_name" {
  type        = string
  default     = "main"   
}

variable "github_secret_name" {
  type        = string
  default     = "github_token"   
}

variable "aws_account_id" {
  type        = string
  default     = "260224488673"
}

variable "ecr_repo_name" {
  type        = string
  default     = "comm-repo"
}

variable "grpc_image_tag" {
  type        = string
  default     = "grpc-server"
}

variable "web_image_tag" {
  type        = string
  default     = "web-server"
}