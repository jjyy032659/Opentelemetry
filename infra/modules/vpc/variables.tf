variable "project" {
  description = "Short project name used in resource names and tags."
  type        = string
}

variable "environment" {
  description = "Environment name, for example dev."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name. Public and private subnets are tagged with it so the AWS Load Balancer Controller can find them."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR for the whole VPC. Subnets are /24 slices of this range."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones. EKS needs at least two."
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 3
    error_message = "az_count must be 2 or 3."
  }
}
