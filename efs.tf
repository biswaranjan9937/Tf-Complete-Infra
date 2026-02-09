module "efs_security_group" {
  source      = "./modules/sg"
  name        = "${title(var.efs_creation_token)}-SG"
  description = "${title(var.efs_creation_token)} Security group"
  vpc_id      = module.vpc.vpc_id


  ingress_rules = var.efs_ingress_rules
  egress_rules  = var.efs_egress_rules

  tags = var.efs_tags
}

module "efs" {
  source = "./modules/efs"

  create               = var.efs_create
  name                 = local.efs_name
  create_backup_policy = var.efs_create_backup_policy
  enable_backup_policy = var.efs_enable_backup_policy
  attach_policy        = var.efs_attach_policy
  performance_mode     = var.efs_performance_mode
  encrypted            = var.efs_encrypted
  kms_key_arn          = module.kms_complete.key_arn
  throughput_mode      = var.efs_throughput_mode
  # mount_targets = {
  #   for az, subnet in {
  #     for i, az in local.efs_azs : az => module.vpc.private_subnets[i + 1]
  #   } : az => { subnet_id = subnet }
  # }
  mount_targets = {
    for i, subnet_id in module.vpc.private_subnets :
    local.efs_azs[i] => {
      subnet_id = subnet_id
    }
  }
  security_group_ids = [module.efs_security_group.security_group_id]
  tags               = var.efs_tags

}
