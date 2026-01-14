output "id" {
  description = "The codepipeline ID."
  value       = aws_codepipeline.this.id
}

output "arn" {
  description = "The codepipeline arn."
  value       = aws_codepipeline.this.arn
}

output "role_arn" {
  description = "ARN of the pipeline role"
  value       = local.role_arn
}

output "role_name" {
  description = "Name of the pipeline role created if var.role_arn is not supplied"
  value       = local.role_name
}

output "bucket_arn" {
  value       = aws_s3_bucket.this.arn
  description = "The ARN of the S3 Bucket project."
}

output "bucket_name" {
  value       = aws_s3_bucket.this.id
  description = "The ARN of the S3 Bucket project."
}

output "cloudwatch_event_role_arn" {
  description = "ARN of the CloudWatch Event role created if var.create_cloudwatch_event_rule is true"
  value       = var.create_cloudwatch_event_rule ? aws_iam_role.cloudwatch_event[0].arn : null
}

output "cloudwatch_event_role_name" {
  description = "Name of the CloudWatch Event role created if var.create_cloudwatch_event_rule is true"
  value       = var.create_cloudwatch_event_rule ? aws_iam_role.cloudwatch_event[0].name : null
}

output "webhook_url" {
  description = "Name of the CloudWatch Event role created if var.create_cloudwatch_event_rule is true"
  value       = var.webhook_enabled ? aws_codepipeline_webhook.this[0].url : null
}

output "webhook_secret" {
  description = "Name of the CloudWatch Event role created if var.create_cloudwatch_event_rule is true"
  value       = var.webhook_enabled ? random_string.webhook_secret : null
}