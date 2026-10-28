output "repository_url" {
  description = "Registry host plus repository name. Use this as the image name, without a tag."
  value       = aws_ecr_repository.ad.repository_url
}

output "repository_arn" {
  description = "ARN of the repository. The CI role is limited to this ARN."
  value       = aws_ecr_repository.ad.arn
}

output "repository_name" {
  description = "Repository name."
  value       = aws_ecr_repository.ad.name
}
