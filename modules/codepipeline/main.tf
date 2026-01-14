resource "aws_iam_role" "pipeline" {
  count = var.role_arn == "" ? 1 : 0
  name  = local.role_name
  path  = "/service-role/"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "inline_policy" {
  count  = var.role_arn == "" ? 1 : 0
  name   = local.role_name
  role   = aws_iam_role.pipeline[0].name
  policy = data.aws_iam_policy_document.pipeline.json
}

resource "aws_codepipeline" "this" {
  name          = var.name
  role_arn      = local.role_arn
  pipeline_type = var.pipeline_type

  artifact_store {
    location = aws_s3_bucket.this.id
    type     = "S3"
    #encryption_key {
    #  id   = var.kms_key_arn
    #  type = "KMS"
    #}
  }

  dynamic "stage" {
    for_each = [for s in var.stages : {
      name   = s.name
      action = s.action
    } if(lookup(s, "enabled", true))]

    content {
      name = stage.value.name
      dynamic "action" {
        for_each = stage.value.action
        content {
          name             = action.value["name"]
          namespace        = lookup(action.value, "namespace", null)
          owner            = action.value["owner"]
          version          = action.value["version"]
          category         = action.value["category"]
          provider         = action.value["provider"]
          input_artifacts  = lookup(action.value, "input_artifacts", [])
          output_artifacts = lookup(action.value, "output_artifacts", [])
          configuration    = lookup(action.value, "configuration", {})
          role_arn         = lookup(action.value, "role_arn", null)
          run_order        = lookup(action.value, "run_order", null)
          region           = lookup(action.value, "region", data.aws_region.current.name)
        }
      }
    }
  }

  tags = var.tags
}

resource "aws_s3_bucket" "this" {
  bucket = var.s3_bucket_name
  tags   = var.tags
}


resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_notification" "this" {
  bucket      = aws_s3_bucket.this.id
  eventbridge = true
}

resource "aws_cloudwatch_event_rule" "this" {
  count         = var.create_cloudwatch_event_rule ? 1 : 0
  name          = "codepipeline-${var.name}-rule"
  description   = "Amazon CloudWatch Events rule to automatically start your pipeline when a change occurs in the Amazon S3 object key or S3 folder."
  event_pattern = var.cloudwatch_event_pattern
}

resource "aws_cloudwatch_event_target" "this" {
  count    = var.create_cloudwatch_event_rule ? 1 : 0
  rule     = aws_cloudwatch_event_rule.this[0].name
  arn      = aws_codepipeline.this.arn
  role_arn = aws_iam_role.cloudwatch_event[0].arn
}

resource "aws_iam_role" "cloudwatch_event" {
  count              = var.create_cloudwatch_event_rule ? 1 : 0
  name               = "${var.name}-cloudwatch-event"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "cloudwatch_event" {
  count = var.create_cloudwatch_event_rule ? 1 : 0
  name  = "start-pipeline-execution"
  role  = aws_iam_role.cloudwatch_event[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["codepipeline:StartPipelineExecution"]
      Resource = [aws_codepipeline.this.arn]
    }]
  })
}

resource "aws_codestarnotifications_notification_rule" "this" {
  count          = var.create_notification_rule ? 1 : 0
  detail_type    = "BASIC"
  event_type_ids = var.notification_rule_event_type_ids

  name     = var.name
  resource = aws_codepipeline.this.arn

  dynamic "target" {
    for_each = length(var.notification_rule_target) > 0 ? var.notification_rule_target : []
    content {
      address = lookup(target.value, "address")
      type    = lookup(target.value, "type", "SNS")
    }
  }
}

resource "random_string" "webhook_secret" {
  count   = var.webhook_enabled ? 1 : 0
  length  = 32
  special = false
}

resource "aws_codepipeline_webhook" "this" {
  count           = var.webhook_enabled ? 1 : 0
  name            = var.name
  authentication  = var.webhook_authentication
  target_action   = var.webhook_target_action
  target_pipeline = aws_codepipeline.this.name

  authentication_configuration {
    secret_token = local.webhook_secret
  }

  filter {
    json_path    = var.webhook_filter_json_path
    match_equals = var.webhook_filter_match_equals
  }

  tags = var.tags
}
