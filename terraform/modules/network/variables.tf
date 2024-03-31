variable "cluster_name" {
  type = string
}

variable "vpc_name" {
  type        = string
}

variable "vpc_cidr" {
  type        = string 
}

variable "private_subnets" {
  type        = list
}

variable "public_subnets" {
  type        = list
}