#------------------------------
# VPC
#------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name                 = "${local.project_name}-vpc"
  cidr                 = var.vpc_subnet_cidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = var.private_subnet_cidr
  public_subnets       = var.public_subnet_cidr
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  ## To identify a cluster's subnets, 
  # the Kubernetes Cloud Controller Manager (cloud-controller-manager) and
  # AWS Load Balancer Controller (aws-load-balancer-controller) query the cluster's subnets
  # by using tag
  # Allow more that one cluster to use subnets 
  tags = {
    Name                                            = "${var.eks_cluster_name}-vpc"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }

  # Allow Kubernetes to use public subnets for external load balancers
  public_subnet_tags = {
    Name                                            = "${var.eks_cluster_name}-eks-public"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                        = 1
  }

  # Allow Kubernetes to use private subnets for internal load balancers
  private_subnet_tags = {
    Name                                            = "${var.eks_cluster_name}-eks-private"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"               = 1
  }
}


#------------------------------
# EKS
#------------------------------
module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "18.26.2"
  cluster_name                    = var.eks_cluster_name
  cluster_version                 = var.eks_k8s_version
  subnet_ids                      = module.vpc.private_subnets
  vpc_id                          = module.vpc.vpc_id
  tags                            = local.tags
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  enable_irsa = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }
  eks_managed_node_groups = local.worker_groups
}


#------------------------------------------------
# Auto Connect to EKS CLuster
#-----------------------------------------------

module "update_kubeconfig" {
  source     = "./modules/null_resources"
  command    = "aws eks update-kubeconfig --name ${var.eks_cluster_name} --region ${var.region}"
  depends_on = [module.eks]

}


#------------------------------------------------
# Nginx Ingress Controller  Installation
#-----------------------------------------------

module "nginx_ingress" {
  source     = "./modules/null_resources"
  command    = "kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud/deploy.yaml; sleep 15;"
  depends_on = [module.update_kubeconfig]
}