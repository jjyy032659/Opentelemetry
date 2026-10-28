variable "project" {
  description = "Short project name used in tags."
  type        = string
}

variable "environment" {
  description = "Environment name used in tags."
  type        = string
}

variable "hosted_zone_id" {
  description = "Route 53 hosted zone that already exists for your domain. This stack does not create or delegate a zone."
  type        = string
}

variable "app_hostname" {
  description = "Name the browser uses, for example shop.example.com. It must be inside the hosted zone. An ACM certificate is requested for this name."
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the load balancer created by the ingress. Leave empty on the first apply. Set it, with alb_zone_id, once kubectl shows the ingress address."
  type        = string
  default     = ""
}

variable "alb_zone_id" {
  description = "Hosted zone id of the load balancer itself (an AWS zone, not your domain). Required once alb_dns_name is set. Printed on the ingress as the load-balancer-hosted-zone-id."
  type        = string
  default     = ""

  validation {
    condition     = var.alb_dns_name == "" || var.alb_zone_id != ""
    error_message = "Set alb_zone_id when alb_dns_name is set."
  }
}
