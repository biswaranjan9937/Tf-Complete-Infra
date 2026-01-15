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
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ALBAccessLogsWrite",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::718504428378:root"
            },
            "Action": [
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": "aws_s3_bucket.alb_log_s3.arn/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_logs_lifecycle" {
  bucket = aws_s3_bucket.alb_log_s3.id

  rule {
    id     = "${var.Project_Name}-alb_access_logs-lifecycle"
    status = "Enabled"
    filter {
      prefix = ""
    }
    expiration {
      days = 30
    }
  }
}