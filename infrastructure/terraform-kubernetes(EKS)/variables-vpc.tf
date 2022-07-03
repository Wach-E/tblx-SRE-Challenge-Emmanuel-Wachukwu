variable "vpc_subnet_cidr" {
  default     = "14.0.0.0/16"
  type        = string
  description = "The VPC Subnet CIDR"
}

variable "private_subnet_cidr" {
  default     = ["14.0.1.0/24", "14.0.2.0/24", "14.0.3.0/24"]
  type        = list(string)
  description = "Private Subnet CIDR"
}

variable "public_subnet_cidr" {
  default     = ["14.0.4.0/24", "14.0.5.0/24", "14.0.6.0/24"]
  type        = list(string)
  description = "Public Subnet CIDR"
}