output "argocd_namespace" {
  description = "Namespace Argo CD was installed into."
  value       = helm_release.argocd.namespace
}

output "load_balancer_controller_release" {
  description = "Helm release name of the AWS Load Balancer Controller."
  value       = helm_release.aws_load_balancer_controller.name
}
