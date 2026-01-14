resource "aws_s3_bucket" "uat_s3_bucket" {
    bucket = var.uat_s3_bucket_name
    
    tags = {
        Name        = "${var.uat_s3_bucket_name}"
        Environment = "UAT"
        Implementedby = "Workmates"
        Managedby   = "Workmates"
        Project     = "Innervex-Technologies"
    }
}
resource "aws_s3_bucket" "prod_s3_bucket" {
    bucket = var.prod_s3_bucket_name
    
    tags = {
        Name        = "${var.prod_s3_bucket_name}"
        Environment = "PROD"
        Implementedby = "Workmates"
        Managedby   = "Workmates"
        Project     = "Innervex-Technologies"
    }
}


####################################################################
# ALB S3 Bucket for Access Logs
####################################################################
resource "aws_s3_bucket" "alb_log_s3" {
    bucket = var.alb_access_logs_s3_bucket
    
    tags = {
        Name        = "${var.alb_access_logs_s3_bucket}"
        Environment = "PROD"
        Implementedby = "Workmates"
        Managedby   = "Workmates"
        Project     = "Innervex-Technologies"
    }
}

resource "aws_s3_bucket_policy" "alb_log_policy" {
  bucket = aws_s3_bucket.alb_log_s3.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::297686227792:root"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_log_s3.arn}/*"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_log_s3.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_logs_lifecycle" {
  bucket = aws_s3_bucket.alb_log_s3.id

  rule {
    id     = "${var.Project_Name}-alb_access_logs-lifecycle"
    status = "Enabled"

    expiration {
      days = 30
    }
  }
}