output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded cluster CA certificate."
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "oidc_provider_arn" {
  description = "IAM OIDC provider ARN for IRSA."
  value       = aws_iam_openid_connect_provider.cluster.arn
}

output "oidc_issuer_host" {
  description = "OIDC issuer host without the https:// prefix. Used in IAM trust policy condition keys."
  value       = local.oidc_issuer_host
}

output "node_role_arn" {
  description = "IAM role attached to the worker nodes."
  value       = aws_iam_role.node.arn
}

output "cluster_security_group_id" {
  description = "Security group EKS created for control-plane and node traffic."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "vpc_id" {
  description = "VPC id passed into the module."
  value       = var.vpc_id
}
