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

    resources = ["arn:aws:s3:::${var.vpc_flowlog_bucket}/AWSLogs/*"]
  }

  statement {
    sid = "AWSLogDeliveryAclCheck"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = ["s3:GetBucketAcl"]

    resources = ["arn:aws:s3:::${var.vpc_flowlog_bucket}"]
  }
}

#################################################
# KMS
#################################################
# Define your custom policy
data "aws_iam_policy_document" "kms_custom_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowAutoScalingServiceLinkedRole"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"]
    }
    actions = [
      "kms:CreateGrant",
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKeyWithoutPlainText",
      "kms:ReEncrypt*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowEBSCSIRole"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.ebs_csi_driver_role.arn]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowEC2EBSService"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["elasticfilesystem.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}


######################################
# EKS
######################################

# Fetch AMI IDs for AMD architecture. This data block is working with EKS version 1.32.
# data "aws_ssm_parameter" "al2_ami_id" {
#   name = "/aws/service/eks/optimized-ami/${var.eks_cluster_version}/amazon-linux-2/recommended/image_id"
# }
# data "aws_ssm_parameter" "al2023_ami_id" {
#   name = "/aws/service/eks/optimized-ami/${var.eks_cluster_version}/amazon-linux-2023/x86_64/standard/recommended/image_id"
# }

#########################################
# EFS
#########################################
# Data source to fetch private subnets by tags
# data "aws_subnets" "private" {
#    filter {
#      name   = "vpc-id"
#      values = [local.efs_vpc_id]
#    }

#    tags = {
#      "Tier"   = "Private"
#    }
#  }

