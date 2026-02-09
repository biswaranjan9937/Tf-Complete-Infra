
module "db_subnet_group" {
  source = "./modules/rds_module/db_subnet_group"

  create = true

  name        = local.rds_subnet_group_name
  description = "${title(local.rds_subnet_group_name)} Subnet group"
  subnet_ids  = module.vpc.database_subnets

  tags = var.rds_subnet_group_tags
}

module "rds_security_group" {
  source      = "./modules/sg"
  name        = "${title(local.rds_identifier)}-sg"
  description = "${title(local.rds_identifier)} Security group"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = var.rds_ingress_rules
  egress_rules  = var.rds_egress_rules

  tags = var.rds_tags
}

module "rds" {
  source     = "./modules/rds_module"
  depends_on = [module.rds_security_group]

  create_db_subnet_group = false
  db_subnet_group_name   = module.db_subnet_group.db_subnet_group_id


  create_db_parameter_group   = true
  parameter_group_name        = local.rds_parameter_group_name
  family                      = var.rds_parameter_group_family
  parameter_group_description = "${title(local.rds_identifier)} parameter group"

  create_db_option_group   = true
  option_group_name        = local.rds_option_group_name
  major_engine_version     = var.rds_options_group_major_engine_version
  option_group_description = "${title(local.rds_identifier)} option group"

  create_db_instance       = true
  identifier               = local.rds_identifier
  engine                   = var.rds_engine
  engine_version           = var.rds_engine_version
  engine_lifecycle_support = var.rds_engine_lifecycle_support
  instance_class           = var.rds_instanceType
  storage_type             = var.rds_storage_type
  allocated_storage        = var.rds_allocated_storage
  max_allocated_storage    = var.rds_max_allocated_storage
  storage_encrypted        = var.rds_storage_encrypted
  kms_key_id               = module.kms_complete.key_arn

  # kms_key_id               = var.rds_kms_key_id #### Need to look into this later.
  network_type = var.rds_network_type

  db_name                = var.rds_db_name
  username               = var.rds_username
  password               = var.rds_password
  port                   = var.rds_port
  vpc_security_group_ids = [module.rds_security_group.security_group_id]

  availability_zone   = var.rds_availability_zone
  multi_az            = var.rds_multi_az
  publicly_accessible = var.rds_publicly_accessible

  apply_immediately           = var.rds_apply_immediately
  auto_minor_version_upgrade  = var.rds_auto_minor_version_upgrade
  allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  maintenance_window          = var.rds_maintenance_window

  backup_retention_period  = var.rds_backup_retention_period
  backup_window            = var.rds_backup_window
  delete_automated_backups = var.rds_delete_automated_backups

  skip_final_snapshot = true
  deletion_protection = var.rds_deletion_protection

  tags = var.rds_tags
}
