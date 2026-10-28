variable "project" {
  description = "Short project name used in role names."
  type        = string
}

variable "environment" {
  description = "Environment name used in role names."
  type        = string
}

variable "github_owner" {
  description = "GitHub organisation or user that owns the repository. Matched exactly in the OIDC subject."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name, without the owner. Matched exactly in the OIDC subject."
  type        = string
}

variable "create_github_oidc_provider" {
  description = "Create the account-wide GitHub OIDC provider. Set false when this account already has one. AWS allows a single provider per URL."
  type        = bool
  default     = true
}

variable "ecr_repository_arn" {
  description = "ARN of the ad image repository. The CI role can push only to this repository."
  type        = string
}

variable "state_bucket_arn" {
  description = "ARN of the Terraform state bucket. The plan role can read it and nothing else in S3."
  type        = string
}

variable "lock_table_arn" {
  description = "ARN of the DynamoDB lock table. The plan role can read and write lock items."
  type        = string
}

variable "eks_oidc_provider_arn" {
  description = "ARN of the cluster's IAM OIDC provider, used by IRSA."
  type        = string
}

variable "eks_oidc_issuer_host" {
  description = "Cluster OIDC issuer host without https://. Used as the IAM condition key."
  type        = string
}
