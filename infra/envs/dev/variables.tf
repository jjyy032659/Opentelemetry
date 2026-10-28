variable "region" {
  description = "AWS region for the dev cluster. ap-southeast-2 is Sydney."
  type        = string
  default     = "ap-southeast-2"
}

variable "project" {
  description = "Short project name used in resource names."
  type        = string
  default     = "otel-gitops"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "github_owner" {
  description = "GitHub user or organisation that owns this repository."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name, without the owner."
  type        = string
}

variable "create_github_oidc_provider" {
  description = "Create the account-wide GitHub OIDC provider. Set false if one already exists."
  type        = bool
  default     = true
}

variable "state_bucket_name" {
  description = "Name of the bootstrap state bucket. Used to scope the plan role."
  type        = string
}

variable "lock_table_name" {
  description = "Name of the bootstrap lock table. Used to scope the plan role."
  type        = string
  default     = "otel-gitops-tf-locks"
}

variable "hosted_zone_id" {
  description = "Existing Route 53 hosted zone id for the domain."
  type        = string
}

variable "app_hostname" {
  description = "Hostname served by the ingress, inside the hosted zone."
  type        = string
}

variable "alb_dns_name" {
  description = "Load balancer DNS name. Empty until the ingress exists."
  type        = string
  default     = ""
}

variable "alb_zone_id" {
  description = "Load balancer hosted zone id. Required once alb_dns_name is set."
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "VPC CIDR."
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.35"
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDRs allowed to reach the public Kubernetes API."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_instance_types" {
  description = "EC2 instance types for the managed node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Initial number of worker nodes."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 3
}

variable "additional_admin_principal_arns" {
  description = "Extra IAM principals to make cluster admins."
  type        = list(string)
  default     = []
}
