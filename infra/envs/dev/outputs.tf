output "region" {
  description = "Region this stack was applied in."
  value       = var.region
}

output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint."
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 cluster CA. The platform stack uses this to install Helm charts."
  value       = module.eks.cluster_certificate_authority_data
}

output "vpc_id" {
  description = "VPC id."
  value       = module.vpc.vpc_id
}

output "lb_controller_role_arn" {
  description = "IRSA role for the AWS Load Balancer Controller."
  value       = module.iam.lb_controller_role_arn
}

output "ecr_repository_url" {
  description = "Push the ad image here. Tags are immutable git SHAs, plus a bootstrap tag for the first manual push."
  value       = module.ecr.repository_url
}

output "acm_certificate_arn" {
  description = "Put this on the ingress annotation alb.ingress.kubernetes.io/certificate-arn."
  value       = module.dns.certificate_arn
}

output "app_hostname" {
  description = "Hostname to put on the ingress rule."
  value       = module.dns.app_hostname
}

output "ad_ci_role_arn" {
  description = "GitHub Actions variable AWS_ROLE_ARN."
  value       = module.iam.ad_ci_role_arn
}

output "terraform_plan_role_arn" {
  description = "GitHub Actions variable AWS_TERRAFORM_ROLE_ARN."
  value       = module.iam.terraform_plan_role_arn
}

output "configure_kubectl" {
  description = "Command that writes a kubeconfig entry for this cluster."
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}"
}
