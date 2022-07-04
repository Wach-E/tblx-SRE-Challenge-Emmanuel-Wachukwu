# Filter eks cluster by name parameter
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

# Filter eks cluster auth by name parameter
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

# Declare the data source for subnets based on availability in region
data "aws_availability_zones" "available" {
  state = "available"
}