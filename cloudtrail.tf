# S3 bucket for CloudTrail
resource "aws_s3_bucket" "cloudtrail" {
  bucket = "innervex-technologies-cloudtrail-s3"

  tags = {
    Name          = "innervex-technologies-cloudtrail"
    Environment   = "PROD"
    Implementedby = "Workmates"
    Managedby     = "Workmates"
    Project       = "Innervex-Technologies"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Bucket policy for CloudTrail
resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail.arn}/*"
        Condition = {
          StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" }
        }
      },
      {
        Effect = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail.arn
      }
    ]
  })
}

# CloudTrail with custom bucket
resource "aws_cloudtrail" "main" {
  name           = "innervex-technologies-cloudtrail"
  s3_bucket_name = aws_s3_bucket.cloudtrail.bucket

  tags = {
    Name          = "innervex-technologies-cloudtrail"
    Environment   = "PROD"
    Implementedby = "Workmates"
    Managedby     = "Workmates"
    Project       = "Innervex-Technologies"
  }
}

# 365 days lifecycle policy
resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail_lifecycle" {
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    id     = "${var.Project_Name}-cloudtrail-lifecycle"
    status = "Enabled"

    expiration {
      days = 365
    }
  }
}