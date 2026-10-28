output "certificate_arn" {
  description = "Issued ACM certificate ARN. Copy it into the ingress annotation."
  value       = aws_acm_certificate_validation.app.certificate_arn
}

output "app_hostname" {
  description = "Hostname the certificate and the alias record use."
  value       = var.app_hostname
}

output "alias_fqdn" {
  description = "Route 53 alias record, or null until alb_dns_name is set and applied."
  value       = try(aws_route53_record.app[0].fqdn, null)
}
