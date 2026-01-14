################################################################################
# Common Locals
################################################################################
locals {
  environment = var.environment
}

################################################################################
# VPC Module
################################################################################
locals {

  vpc_name = "${var.vpc_name}-${local.environment}"
  vpc_cidr = var.vpc_cidr
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  single_nat_gateway = var.single_nat_gateway
  enable_nat_gateway = var.enable_nat_gateway

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  vpc_tags             = var.vpc_tags
  vpc_flowlog_bucket   = var.vpc_flowlog_bucket
}
####################################################################
# KMS
####################################################################
locals {
  kms_tags                    = var.kms_tags
  region                      = var.kms_region
  key_description             = var.key_description
  key_aliases                 = var.key_aliases
  key_deletion_window_in_days = var.key_deletion_window_in_days
  key_usage                   = var.key_usage
}
####################################################################
# PRITUNL
####################################################################

locals {
  ec2_pritunl_key_name      = var.ec2_pritunl_key_name
  ec2_pritunl_name          = "CWM-Talent-Talker-${local.environment}-${var.ec2_pritunl_name}"
  ec2_pritunl_ingress_rules = var.ec2_pritunl_ingress_rules
  ec2_pritunl_egress_rules  = var.ec2_pritunl_egress_rules
  ec2_pritunl_ami_id        = var.ec2_pritunl_ami_id
  ec2_pritunl_instance_type = var.ec2_pritunl_instance_type
  #ec2_pritunl_iam_role_name           = var.ec2_pritunl_iam_role_name
  ec2_pritunl_iam_role_policies       = var.ec2_pritunl_iam_role_policies
  ec2_pritunl_volume_type             = var.ec2_pritunl_volume_type
  ec2_pritunl_volume_size             = var.ec2_pritunl_volume_size
  ec2_pritunl_kms_key_id              = module.kms_complete.key_arn
  ec2_pritunl_root_encrypted          = var.ec2_pritunl_root_encrypted
  ec2_pritunl_ebs_block_devices       = var.ec2_pritunl_ebs_block_devices
  ec2_pritunl_tags                    = var.ec2_pritunl_tags
  ec2_pritunl_disable_api_termination = var.ec2_pritunl_termination_protection
  ec2_pritunl_iam_instance_profile    = var.ec2_pritunl_iam_instance_profile
  bucketName                          = var.cred_bucketName
   bucketTags                          = var.bucketTags

}
#####################################################################
# RDS
####################################################################

locals {
  rds_subnet_group_name = "${var.rds_subnet_group_name}-poc"
  rds_subnet_group_tags = var.rds_subnet_group_tags

  rds_identifier                         = "${var.rds_identifier}-poc-rds"
  rds_instanceType                       = var.rds_instanceType
  rds_parameter_group_name               = "poc-${var.rds_parameter_group_name}"
  rds_option_group_name                  = "poc-${var.rds_option_group_name}"
  rds_options_group_major_engine_version = var.rds_options_group_major_engine_version
  rds_parameter_group_family             = var.rds_parameter_group_family
  rds_engine                             = var.rds_engine
  rds_engine_version                     = var.rds_engine_version
  rds_storage_type                       = var.rds_storage_type
  rds_allocated_storage                  = var.rds_allocated_storage
  rds_max_allocated_storage              = var.rds_max_allocated_storage
  rds_storage_encrypted                  = var.rds_storage_encrypted
  rds_kms_key_id                         = module.kms_complete.key_arn
  rds_network_type                       = var.rds_network_type
  rds_db_name                            = var.rds_db_name
  rds_username                           = var.rds_username
  rds_password                           = var.rds_password
  rds_port                               = var.rds_port
  rds_availability_zone                  = var.rds_availability_zone
  rds_multi_az                           = var.rds_multi_az
  rds_publicly_accessible                = var.rds_publicly_accessible
  rds_tags                               = var.rds_tags
  rds_apply_immediately                  = var.rds_apply_immediately
  rds_auto_minor_version_upgrade         = var.rds_auto_minor_version_upgrade
  rds_ingress_rules                      = var.rds_ingress_rules
  rds_egress_rules                       = var.rds_egress_rules
  rds_allow_major_version_upgrade        = var.rds_allow_major_version_upgrade
  rds_maintenance_window                 = var.rds_maintenance_window
  rds_backup_retention_period            = var.rds_backup_retention_period
  rds_backup_window                      = var.rds_backup_window
  rds_delete_automated_backups           = var.rds_delete_automated_backups
  rds_deletion_protection                = var.rds_deletion_protection
  rds_engine_lifecycle_support           = var.rds_engine_lifecycle_support
  #rds_snapshot_identifier                = var.rds_snapshot_identifier
}
####################################################################
# ECR
####################################################################
# locals {
#   ecr_tags         = var.ecr_tags
#   ecr_kms_key_arn  = module.kms_complete.key_arn
#   repository_names = var.repository_names
# }
####################################################################
# S3
####################################################################
# locals {
#   s3_env_bucket = "revupai-env-bucket"
# }
# ####################################################################
# # ALB
# # ####################################################################
# locals {
#   alb_name = "RevUpAI-POC-alb"
#   alb_tags = {

#   }
#   alb_vpc_id = module.vpc.vpc_id
#   alb_global_egress_rules = [{
#     cidr_blocks = ["0.0.0.0/0"]
#     from_port   = 0
#     protocol    = "-1"
#     to_port     = 0
#   }]
#   alb_global_ingress_rules = [
#     {
#       cidr_blocks = ["0.0.0.0/0"]
#       from_port   = 80
#       protocol    = "tcp"
#       to_port     = 80
#     },
#     {
#       cidr_blocks = ["0.0.0.0/0"]
#       from_port   = 443
#       protocol    = "tcp"
#       to_port     = 443
#     }
#   ]
# }
####################################################################
# ECS
####################################################################
locals {
  ecs_cluster_name     = "${var.ecs_cluster_name}-${local.environment}-cluster"
  ecs_cluster_settings = var.ecs_cluster_settings
  ecs_cluster_tags     = var.ecs_cluster_tags
  ecs_account_setting_default = {
    "awsvpcTrunking" = "enabled"
  }
}
####################################################################
# bedrock, recognition , polly
####################################################################
# locals {
#   common_tags = {
#     Environment = var.environment
#     Project     = "Talent-Talker-ECS"
#     ManagedBy   = "Terraform"
#     # Add any other common tags you want to use
#   }
# }