module "efs_security_group" {
  source      = "./modules/sg"
  name        = "${title(local.efs_name)}-SG"
  description = "${title(local.efs_name)} Security Group"
  vpc_id      = module.vpc.vpc_id


  ingress_rules = var.efs_ingress_rules
  egress_rules  = var.efs_egress_rules

  tags = merge(var.efs_tags, {
    Name        = "${title(local.efs_name)}-SG",
    Environment = var.environment,
    Project     = var.project_name
  })
}

module "efs" {
  source = "./modules/efs"

  create               = var.efs_create
  name                 = local.efs_name
  create_backup_policy = var.efs_create_backup_policy
  enable_backup_policy = var.efs_enable_backup_policy
  performance_mode     = var.efs_performance_mode
  encrypted            = var.efs_encrypted
  kms_key_arn          = module.aws_cmk.key_arn
  throughput_mode      = var.efs_throughput_mode

  lifecycle_policy = {
    transition_to_ia                    = "AFTER_30_DAYS",
    transition_to_archive               = "AFTER_90_DAYS",
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }

  # File system policy
  attach_policy = var.efs_attach_policy
  # bypass_policy_lockout_safety_check = false
  # policy_statements = [   #### This will allow who can mount the EFS file system. You can add multiple statements.
  #   {
  #     sid     = "Example"
  #     actions = ["elasticfilesystem:ClientMount"]
  #     principals = [
  #       {
  #         type        = "AWS"
  #         identifiers = ["arn:aws:iam::111122223333:role/EfsReadOnly"]
  #       }
  #     ]
  #   }
  # ]

  mount_targets = {
    for i, subnet_id in module.vpc.private_subnets :
    local.efs_azs[i] => {
      subnet_id = subnet_id
    }
  }

  security_group_ids = [module.efs_security_group.security_group_id]

  tags = merge(var.efs_tags, {
    Name        = "${title(local.efs_name)}",
    Environment = var.environment,
    Project     = var.project_name
  })

}
