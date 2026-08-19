module "aws_cmk" { ### Region comes from the provider block
  source                  = "./modules/kms"
  create                  = true
  is_enabled              = var.enable_key
  deletion_window_in_days = var.key_deletion_window_in_days
  description             = var.key_description
  enable_key_rotation     = var.enable_key_rotation
  key_usage               = var.key_usage
  multi_region            = var.enable_multi_region
  enable_default_policy   = false

  # Custom policy
  policy = data.aws_iam_policy_document.kms_custom_policy.json

  # key_owners         = var.key_administrators_list
  key_administrators = var.key_administrators_list
  key_users          = var.key_user_list
  # key_service_users  = var.key_user_list

  aliases                 = local.alias_name
  aliases_use_name_prefix = false
  tags = merge(var.kms_tags, {
    Name        = "${var.project_name}-${var.environment}-CMK",
    Environment = var.environment,
    Project     = var.project_name
  })

}

data "aws_iam_policy_document" "kms_additional_policy" {
  # statement {
  #   sid    = "AllowAutoScalingServiceLinkedRole"
  #   effect = "Allow"
  #   principals {
  #     type        = "AWS"
  #     identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"]
  #   }
  #   actions = [
  #     "kms:CreateGrant",
  #     "kms:Decrypt",
  #     "kms:DescribeKey",
  #     "kms:GenerateDataKeyWithoutPlaintext",
  #     "kms:ReEncrypt*"
  #   ]
  #   resources = ["*"]
  # }

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
}

resource "aws_kms_key_policy" "additional" {
  key_id = module.aws_cmk.key_id
  policy = data.aws_iam_policy_document.kms_merged_policy.json

  depends_on = [aws_iam_role.ebs_csi_driver_role, module.aws_cmk]
}

data "aws_iam_policy_document" "kms_merged_policy" {
  source_policy_documents = [
    data.aws_iam_policy_document.kms_custom_policy.json,
    data.aws_iam_policy_document.kms_additional_policy.json
  ]
}