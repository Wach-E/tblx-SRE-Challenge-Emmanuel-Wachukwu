variable "eks_cluster_name" {
  default = "tblx-challenge-sre"
  type    = string
}

variable "eks_k8s_version" {
  type    = string
  default = "1.22"
}

# variable "eks_map_users" {
#   description = "Additional IAM users to add to the aws-auth configmap."
#   type = list(object({
#     userarn  = string
#     username = string
#     groups   = list(string)
#   }))

#   default = [
#   ]
# }