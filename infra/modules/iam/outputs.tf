output "github_oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC provider, whether this stack created it or reused the account's existing one."
  value       = local.github_oidc_provider_arn
}

output "ad_ci_role_arn" {
  description = "Role ARN for the ad-service GitHub Actions workflow. Store it as the AWS_ROLE_ARN repository variable."
  value       = aws_iam_role.ad_ci.arn
}

output "terraform_plan_role_arn" {
  description = "Role ARN for the Terraform plan workflow. Store it as the AWS_TERRAFORM_ROLE_ARN repository variable."
  value       = aws_iam_role.terraform_plan.arn
}

output "lb_controller_role_arn" {
  description = "Role ARN annotated onto the AWS Load Balancer Controller service account."
  value       = aws_iam_role.lb_controller.arn
}
