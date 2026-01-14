########################################################################
# AWS Polly Module
########################################################################

resource "aws_polly_lexicon" "this" {
  count = var.create_lexicon ? 1 : 0

  name = var.lexicon_name
  content = var.lexicon_content

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.lexicon_name}"
    }
  )
}

resource "aws_s3_bucket" "polly_output" {
  count = var.create_output_bucket ? 1 : 0

  bucket = var.output_bucket_name != null ? var.output_bucket_name : "${var.environment}-polly-output-${random_string.bucket_suffix[0].result}"
  force_destroy = var.force_destroy_bucket

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-polly-output"
    }
  )
}

resource "random_string" "bucket_suffix" {
  count   = var.create_output_bucket ? 1 : 0
  length  = 8
  special = false
  lower   = true
  upper   = false
}

resource "aws_s3_bucket_public_access_block" "polly_output" {
  count = var.create_output_bucket ? 1 : 0

  bucket = aws_s3_bucket.polly_output[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "polly_output" {
  count = var.create_output_bucket ? 1 : 0

  bucket = aws_s3_bucket.polly_output[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "polly_output" {
  count = var.create_output_bucket && var.enable_lifecycle_rules ? 1 : 0

  bucket = aws_s3_bucket.polly_output[0].id

  rule {
    id = "expire-old-files"
    status = "Enabled"

    expiration {
      days = var.expiration_days
    }
  }
}

resource "aws_iam_role" "polly_role" {
  count = var.create_iam_role ? 1 : 0

  name = "${var.environment}-polly-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "polly.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-polly-role"
    }
  )
}

resource "aws_iam_policy" "polly_s3_access" {
  count = var.create_iam_role ? 1 : 0

  name        = "${var.environment}-polly-s3-access"
  description = "Policy for Polly to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = var.create_output_bucket ? [
          aws_s3_bucket.polly_output[0].arn,
          "${aws_s3_bucket.polly_output[0].arn}/*"
        ] : [
          "arn:aws:s3:::${var.output_bucket_name}",
          "arn:aws:s3:::${var.output_bucket_name}/*"
        ]
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-polly-s3-access"
    }
  )
}

resource "aws_iam_role_policy_attachment" "polly_s3_access" {
  count = var.create_iam_role ? 1 : 0

  role       = aws_iam_role.polly_role[0].name
  policy_arn = aws_iam_policy.polly_s3_access[0].arn
}

resource "aws_cloudwatch_log_group" "polly_logs" {
  count = var.create_log_group ? 1 : 0

  name              = "/aws/polly/${var.environment}"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-polly-logs"
    }
  )
}
