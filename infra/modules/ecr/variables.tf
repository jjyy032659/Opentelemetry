variable "repository_name" {
  description = "ECR repository name. One repository for the ad service."
  type        = string
}

variable "project" {
  description = "Short project name used in tags."
  type        = string
}

variable "environment" {
  description = "Environment name used in tags."
  type        = string
}
