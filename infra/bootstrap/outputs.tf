output "state_bucket_name" {
  description = "Copy this into backend.hcl as bucket."
  value       = aws_s3_bucket.state.id
}

output "state_bucket_arn" {
  description = "ARN of the state bucket."
  value       = aws_s3_bucket.state.arn
}

output "lock_table_name" {
  description = "Copy this into backend.hcl as dynamodb_table."
  value       = aws_dynamodb_table.locks.name
}

output "lock_table_arn" {
  description = "ARN of the lock table."
  value       = aws_dynamodb_table.locks.arn
}

output "region" {
  description = "Region the state resources were created in."
  value       = var.region
}
