variable "region" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "app_name" {
  type = string
}
variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list
}

variable "node_group_name" {
  type = string
}

variable "eksnode_image" {
  type = string
}

variable "codebuild_role_arn" {
  type = string
}

variable "eks_instance_types" {
  type = list
}

