variable "region" {
  description = "Region of the state bucket and the cluster. Passed to `aws eks get-token`."
  type        = string
  default     = "ap-southeast-2"
}

variable "state_bucket" {
  description = "Bootstrap state bucket. This stack reads the dev outputs from it."
  type        = string
}

variable "dev_state_key" {
  description = "State key written by infra/envs/dev."
  type        = string
  default     = "envs/dev/terraform.tfstate"
}
