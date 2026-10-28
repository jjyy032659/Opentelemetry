variable "region" {
  description = "Region for the state bucket and the lock table. Use the same region as the dev stack."
  type        = string
  default     = "ap-southeast-2"
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state. Include the account id so it cannot collide."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.state_bucket_name))
    error_message = "state_bucket_name must be a valid DNS-style S3 bucket name."
  }
}

variable "lock_table_name" {
  description = "DynamoDB table Terraform uses as the state lock. The hash key must stay LockID."
  type        = string
  default     = "otel-gitops-tf-locks"
}

variable "force_destroy" {
  description = "Allow terraform destroy to delete the bucket even when it still holds state objects. Leave false until you have emptied it on purpose."
  type        = bool
  default     = false
}
