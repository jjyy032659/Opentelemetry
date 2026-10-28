variable "project" {
  description = "Short project name used in resource names."
  type        = string
}

variable "environment" {
  description = "Environment name, for example dev."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version. Confirm it is still in standard support before apply: aws eks describe-addon-versions --addon-name vpc-cni."
  type        = string
  default     = "1.35"
}

variable "vpc_id" {
  description = "VPC the cluster is created in. Recorded for outputs and for callers that tag related resources."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets for the worker nodes."
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnets. Passed to the cluster so the control plane knows about the subnets the load balancer will use."
  type        = list(string)
}

variable "public_access_cidrs" {
  description = "CIDRs allowed to call the public Kubernetes API. Tighten this to your own IP before leaving the cluster up."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "instance_types" {
  description = "EC2 instance types for the managed node group. t3.medium is the smallest size that comfortably runs this slice plus Argo CD."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "ami_type" {
  description = "EKS AMI family. AL2023 is the current Amazon Linux node image."
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}

variable "capacity_type" {
  description = "ON_DEMAND or SPOT. On-demand keeps a demo from being interrupted."
  type        = string
  default     = "ON_DEMAND"
}

variable "disk_size" {
  description = "Root volume size in GiB. The node pulls several service images, so 20 GiB is tight."
  type        = number
  default     = 30
}

variable "desired_size" {
  description = "Initial node count. Later changes made outside Terraform are left alone."
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum node count."
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum node count."
  type        = number
  default     = 3
}

variable "additional_admin_principal_arns" {
  description = "Extra IAM principals (users or roles, not assumed-role session ARNs) that should be cluster admins. The principal that runs apply is already an admin."
  type        = list(string)
  default     = []
}
