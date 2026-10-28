# DNS validation so the certificate is issued without an email click. The
# records are created in the zone you already own. The certificate must be in
# the same region as the load balancer, which is this provider's region.
resource "aws_acm_certificate" "app" {
  domain_name       = var.app_hostname
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = var.app_hostname
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.app.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id         = var.hosted_zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.record]
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "app" {
  certificate_arn         = aws_acm_certificate.app.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# The alias cannot be created on the first apply: the load balancer does not
# exist until the ingress is synced. Leave alb_dns_name empty, deploy the
# workload, then set the name and apply again. count keeps the record out of
# the plan until both values are known.
resource "aws_route53_record" "app" {
  count = var.alb_dns_name == "" ? 0 : 1

  zone_id = var.hosted_zone_id
  name    = var.app_hostname
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
