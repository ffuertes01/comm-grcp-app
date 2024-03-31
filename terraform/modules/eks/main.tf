module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  vpc_id                         = var.vpc_id
  subnet_ids                     = var.private_subnets
  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }
  

  eks_managed_node_groups = {
    one = {
      name = var.node_group_name

      instance_types = var.eks_instance_types
      capacity_type  = "ON_DEMAND"

      min_size     = 1
      max_size     = 1
      desired_size = 1

      metadata_options = {
       instance_metadata_tags      = "disabled"
      }

    }
  }
   
  enable_cluster_creator_admin_permissions = true

}

# IAM Role for ALB Controller
module "lb_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "${var.app_name}_eks_lb"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

# Data
data "aws_eks_cluster" "comm" {
  name = var.cluster_name
  depends_on = [
    module.eks
	]
}

data "aws_eks_node_group" "nodes" {
  cluster_name    = var.cluster_name
  node_group_name = trimprefix(module.eks.eks_managed_node_groups.one.node_group_id, "${var.cluster_name}:") 
  depends_on = [
    module.eks
	]  
}

# K8s Providers
provider "kubernetes" {
  host                   = data.aws_eks_cluster.comm.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.comm.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.comm.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.comm.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command     = "aws"
    }
  }
}

# Service Account for ALB Controller
resource "kubernetes_service_account" "service-account" {
  metadata {
    name = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
        "app.kubernetes.io/name"= "aws-load-balancer-controller"
        "app.kubernetes.io/component"= "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = module.lb_role.iam_role_arn    
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

# ALB Controller
resource "helm_release" "lb" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  depends_on = [
    kubernetes_service_account.service-account
  ]

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "image.repository"
    value =  var.eksnode_image
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "clusterName"
    value = var.cluster_name
  }
}

# Modify EKS aws-auth configmap to allow Codebuild write into the cluster
resource "kubernetes_config_map_v1_data" "aws_auth_configmap" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles = <<YAML
- rolearn: ${data.aws_eks_node_group.nodes.node_role_arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
- rolearn: ${var.codebuild_role_arn}
  username: kubectl-access-user2
  groups:
    - system:masters
YAML
  }
  force = true
}