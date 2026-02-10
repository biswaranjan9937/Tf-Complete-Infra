module "kms_complete" { ### Region comes from the provider block
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

  aliases                 = var.key_aliases
  aliases_use_name_prefix = false
  tags                    = var.kms_tags

  depends_on = [aws_iam_role.ebs_csi_driver_role]
  
}