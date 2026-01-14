########################################################################
# Polly Lexicon Outputs
########################################################################
output "lexicon_name" {
  description = "Name of the Polly lexicon"
  value       = try(aws_polly_lexicon.this[0].name, null)
}

########################################################################
# S3 Output Bucket Outputs
########################################################################
output "output_bucket_id" {
  description = "ID of the S3 bucket for Polly output"
  value       = try(aws_s3_bucket.polly_output[0].id, null)
}

output "output_bucket_arn" {
  description = "ARN of the S3 bucket for Polly output"
  value       = try(aws_s3_bucket.polly_output[0].arn, null)
}

output "output_bucket_domain_name" {
  description = "Domain name of the S3 bucket for Polly output"
  value       = try(aws_s3_bucket.polly_output[0].bucket_domain_name, null)
}

########################################################################
# IAM Role Outputs
########################################################################
output "polly_role_id" {
  description = "ID of the IAM role for Polly"
  value       = try(aws_iam_role.polly_role[0].id, null)
}

output "polly_role_arn" {
  description = "ARN of the IAM role for Polly"
  value       = try(aws_iam_role.polly_role[0].arn, null)
}

########################################################################
# CloudWatch Logs Outputs
########################################################################
output "log_group_name" {
  description = "Name of the CloudWatch log group for Polly"
  value       = try(aws_cloudwatch_log_group.polly_logs[0].name, null)
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group for Polly"
  value       = try(aws_cloudwatch_log_group.polly_logs[0].arn, null)
}
