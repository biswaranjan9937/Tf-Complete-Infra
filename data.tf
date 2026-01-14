data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {}
####################################################################
# PRITUNL
####################################################################
data "aws_iam_policy_document" "flow_log_s3" {
  statement {
    sid = "AWSLogDeliveryWrite"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = ["arn:aws:s3:::${local.vpc_flowlog_bucket}/AWSLogs/*"]
  }

  statement {
    sid = "AWSLogDeliveryAclCheck"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = ["s3:GetBucketAcl"]

    resources = ["arn:aws:s3:::${local.vpc_flowlog_bucket}"]
  }
}


####################################################################
# EC2 - UAT
####################################################################
data "aws_key_pair" "uat" {
  key_name           = var.uat_key_name
  include_public_key = true
}

####################################################################
# EC2 - PROD
####################################################################
data "aws_key_pair" "prod" {
  key_name           = var.prod_key_name
  include_public_key = true
}