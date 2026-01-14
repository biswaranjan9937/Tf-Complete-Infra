locals {
  role_arn       = var.role_arn == "" ? aws_iam_role.pipeline[0].arn : var.role_arn
  role_name      = var.role_name == "" ? "AWSCodePipelineServiceRole-${data.aws_region.current.name}-${var.name}" : var.role_name
  webhook_secret = join("", random_string.webhook_secret.*.result)
  webhook_url    = join("", aws_codepipeline_webhook.this.*.url)
}