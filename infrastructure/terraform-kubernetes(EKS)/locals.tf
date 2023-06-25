# A local value assigns a name to an expression, 
# so you can use it multiple times within a module without repeating it
# https://www.terraform.io/docs/configuration/locals.html

locals {
  project_name = "tblx-challenge-sre"
  tags = {
    managed-by = "terraform"
  }

  #   maps_users = [
  #     {
  #       userarn  = "arn:aws:iam::$ACCOUNT_ID:user/babamame247@yahoo.com"
  #       username = "babamame247@yahoo.com"
  #       groups   = ["system:masters"]
  #     },
  #   ]

  worker_groups = {
    workers = {
      security_group_rules = [{
        type        = "egress"
        cidr_blocks = ["0.0.0.0/0"]
        to_port     = 0
        from_port   = 0
        protocol    = "-1"
        },
        {
          type        = "ingress"
          to_port     = 0
          cidr_blocks = ["0.0.0.0/0"]
          from_port   = 0
          protocol    = "-1"
        }
      ]

      min_size     = 2
      max_size     = 4
      desired_size = 2

      instance_types = ["t2.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }
}
