
# module "db_subnet_group" {
#   source = "./modules/rds_module/db_subnet_group"

#   create = true

#   name        = local.rds_subnet_group_name
#   description = title(local.rds_subnet_group_name)
#   subnet_ids  = module.vpc.private_subnets

#   tags = merge(var.rds_tags, {
#     Name        = title(local.rds_subnet_group_name),
#     Environment = var.environment,
#     Project     = var.project_name
#   })
# }

# module "rds_security_group" {
#   source      = "./modules/sg"
#   name        = "${title(local.rds_identifier)}-sg"
#   description = "${title(local.rds_identifier)} Security group"
#   vpc_id      = module.vpc.vpc_id

#   ingress_rules = var.rds_ingress_rules
#   egress_rules  = var.rds_egress_rules

#   tags = merge(var.rds_tags, {
#     Name        = "${title(local.rds_identifier)}-sg",
#     Environment = var.environment,
#     Project     = var.project_name
#   })
# }

# module "rds" {
#   source     = "./modules/rds_module"
#   depends_on = [module.rds_security_group]

#   create_db_subnet_group = false #### Since we are creating the subnet group separately, we can set this to false and provide the name of the subnet group in the db_subnet_group_name variable.
#   db_subnet_group_name   = module.db_subnet_group.db_subnet_group_id

#   create_db_parameter_group   = true
#   parameter_group_name        = local.rds_parameter_group_name
#   family                      = var.rds_parameter_group_family
#   parameter_group_description = "${title(local.rds_identifier)} parameter group"
#   parameters                  = var.parameters

#   create_db_option_group   = true
#   option_group_name        = local.rds_option_group_name
#   major_engine_version     = var.rds_options_group_major_engine_version
#   option_group_description = "${title(local.rds_identifier)} option group"

#   create_db_instance       = true
#   identifier               = local.rds_identifier
#   engine                   = var.rds_engine
#   engine_version           = var.rds_engine_version
#   engine_lifecycle_support = var.rds_engine_lifecycle_support
#   instance_class           = var.rds_instanceType
#   storage_type             = var.rds_storage_type
#   allocated_storage        = var.rds_allocated_storage ## The allocated storage should be greater than or equal to the size of the snapshot that we are restoring from. If the snapshot is larger than the allocated storage, the restore will fail.
#   max_allocated_storage    = var.rds_max_allocated_storage
#   storage_encrypted        = var.rds_storage_encrypted
#   kms_key_id               = module.aws_cmk.key_arn

#   network_type = var.rds_network_type

#   db_name                = var.rds_db_name  ## commented out because we are restoring from a snapshot, so we don't need to specify the database name.
#   username               = var.rds_username ## commented out because we are restoring from a snapshot, so we don't need to specify the username and password.
#   password               = var.rds_password ## commented out because we are restoring from a snapshot, so we don't need to specify the username and password.
#   port                   = var.rds_port
#   vpc_security_group_ids = [module.rds_security_group.security_group_id]

#   availability_zone   = element(local.azs, 1) ### 
#   multi_az            = var.rds_multi_az
#   publicly_accessible = var.rds_publicly_accessible

#   apply_immediately           = var.rds_apply_immediately
#   auto_minor_version_upgrade  = var.rds_auto_minor_version_upgrade
#   allow_major_version_upgrade = var.rds_allow_major_version_upgrade
#   maintenance_window          = var.rds_maintenance_window

#   backup_retention_period  = var.rds_backup_retention_period
#   backup_window            = var.rds_backup_window
#   delete_automated_backups = var.rds_delete_automated_backups

#   skip_final_snapshot = true
#   # snapshot_identifier = var.rds_snapshot_identifier ## This is the new variable that we added to restore the RDS instance from a snapshot. It can be either the ARN or ID of the snapshot. comment this if you want to create a new RDS instance instead of restoring from a snapshot.
#   deletion_protection = var.rds_deletion_protection

#   tags = merge(var.rds_tags, {
#     Name        = "${title(local.rds_identifier)}",
#     Environment = var.environment,
#     Project     = var.project_name
#   })
# }
