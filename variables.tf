variable "environment" {
  type = string
}
variable "region_backend" {
  type = string
}

variable "Project_Name" {
  type = string
}

########################################################################
# VPC
########################################################################

variable "vpc_name" {
  description = "The name of the project."
  type        = string

}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "region" {
  description = "The AWS region in which the VPC will be created."
  type        = string
}


variable "single_nat_gateway" {
  description = "Whether to create a single NAT Gateway in the first public subnet."
  type        = bool
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT Gateways for each private subnet."
  type        = bool
}

variable "enable_dns_hostnames" {
  description = "Whether instances with public IP addresses should get corresponding DNS hostnames."
  type        = bool
}

variable "enable_dns_support" {
  description = "Whether the VPC should have DNS support."
  type        = bool
}

variable "vpc_tags" {
  type = map(string)
}

variable "vpc_flowlog_bucket" {
  type    = string
  default = "toucan-uat-vpc-flowlog-bucket"
}



########################################################################
# PRITUNL
########################################################################
variable "ec2_pritunl_ami_id" {
  type = string
}
variable "ec2_pritunl_instance_type" {
  type = string
}
variable "ec2_pritunl_name" {
  type = string
}
# variable "ec2_pritunl_iam_role_name" {
#   type = string
# }
variable "ec2_pritunl_iam_role_policies" {
  type    = map(string)
  default = {}
}
variable "ec2_pritunl_volume_type" {
  type = string
}
variable "ec2_pritunl_volume_size" {
  type = string
}
# variable "ec2_pritunl_kms_key_id" {
#   type = string
# }
variable "ec2_pritunl_root_encrypted" {
  type = bool
}
variable "ec2_pritunl_ebs_block_devices" {
  type    = list(any)
  default = []
}
variable "ec2_pritunl_tags" {
  type = map(string)
}
variable "ec2_pritunl_key_name" {
  type = string
}
variable "ec2_pritunl_termination_protection" {
  type = bool
}
variable "ec2_pritunl_iam_instance_profile" {
  type    = string
  default = ""
}
variable "ec2_pritunl_ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "ec2_pritunl_egress_rules" {
  description = "List of egress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}
variable "bucketTags" {
  type = map(string)
}
variable "cred_bucketName" {
  type = string
}

#######################################################################
# KMS
#######################################################################

variable "kms_tags" {
  type = map(string)
}
variable "key_user_list" {
  type = list(string)
}

variable "key_administrators_list" {
  type = list(string)
}
variable "enable_multi_region" {
  type = bool
}

variable "enable_key_rotation" {
  type = bool
}

variable "enable_key" {
  type = bool
}

variable "key_aliases" {
  type = list(string)
}

variable "key_description" {
  type = string
}

variable "key_deletion_window_in_days" {
  type = number
}

variable "key_usage" {
  type = string
}
variable "kms_region" {
  type = string
}


######################################
# ACM
######################################
variable "main_domain_name" {
  type = string
}

variable "create_route53_records" {
  type = bool
}

variable "validation_method" {
  type = string
}

variable "acm_main_tags" {
  type = map(string)
}


########################################################################
# EC2 - UAT
########################################################################
# variable "availability_zone" {
#   type = string
# }
# variable "uat_ec2_key_name" {
#   type = string
# }
# variable "uat_ami_id" {
#   type = string
# }
# variable "uat_instance_type" {
#   type = string
# }
# variable "uat_name" {
#   type = string
# }
# variable "uat_iam_role_policies" {
#   type    = map(string)
#   default = {}
# }
# variable "uat_volume_type" {
#   type = string
# }
# variable "uat_root_volume_size" {
#   type = string
# }
# variable "uat_ebs_volume_size" {
#   type = string
# }
# variable "uat_root_encrypted" {
#   type = bool
# }
# variable "uat_ebs_block_devices" {
#   type    = list(any)
#   default = []
# }
# variable "uat_tags" {
#   type = map(string)
# }
# variable "uat_termination_protection" {
#   type = bool
# }
# variable "uat_iam_instance_profile" {
#   type = string
# }
# variable "uat_ingress_rules" {
#   description = "List of ingress rules"
#   type = list(object({
#     from_port   = number
#     to_port     = number
#     protocol    = string
#     cidr_blocks = list(string)
#   }))
#   default = []
# } 

# variable "uat_egress_rules" {
#   description = "List of egress rules"
#   type = list(object({
#     from_port   = number
#     to_port     = number
#     protocol    = string
#     cidr_blocks = list(string)
#   }))
#   default = []
# }     


########################################################################
# EC2 - PROD
########################################################################

# variable "prod_ec2_key_name" {
#   type = string
# }
# variable "prod_ami_id" {
#   type = string
# }
# variable "prod_instance_type" {
#   type = string
# }
# variable "prod_name" {
#   type = string
# }
# variable "prod_iam_role_policies" {
#   type    = map(string)
#   default = {}
# }
# variable "prod_volume_type" {
#   type = string
# }
# variable "prod_root_volume_size" {
#   type = string
# }
# variable "prod_ebs_volume_size" {
#   type = string
# }
# variable "prod_root_encrypted" {
#   type = bool
# }
# variable "prod_ebs_block_devices" {
#   type    = list(any)
#   default = []
# }
# variable "prod_tags" {
#   type = map(string)
# }
# variable "prod_termination_protection" {
#   type = bool
# }
# variable "prod_iam_instance_profile" {
#   type = string
# }
# variable "prod_ingress_rules" {
#   description = "List of ingress rules"
#   type = list(object({
#     from_port   = number
#     to_port     = number
#     protocol    = string
#     cidr_blocks = list(string)
#   }))
#   default = []
# } 

# variable "prod_egress_rules" {
#   description = "List of egress rules"
#   type = list(object({
#     from_port   = number
#     to_port     = number
#     protocol    = string
#     cidr_blocks = list(string)
#   }))
#   default = []
# } 


########################################################################
# ALB
########################################################################
# variable "alb_sg_name" {
#   type = string
# }
# variable "alb_name" {
#   type = string
# }
# variable "uat_ec2_tg_name" {
#   type = string
# }
# variable "alb_access_logs_s3_bucket" {
#   type = string
# }
# variable "alb_access_logs_s3_prefix" {
#   type = string
# }


########################################################################
# S3
########################################################################
# variable "uat_s3_bucket_name" {
#   type = string
# }
# variable "prod_s3_bucket_name" {
#   type = string
# }

################################
# Budget
################################
# variable "budget_amount" {
#   description = "Monthly budget amount in USD"
#   type        = string
# }

# variable "anomaly_threshold" {
#   description = "Threshold for cost anomaly detection"
#   type        = string
# }

#######################################################################
# EKS
#######################################################################
variable "eks_cluster_name" {
  type = string
}
variable "eks_cluster_version" {
  type = string
}
variable "eks_cluster_endpoint_public_access" {
  type = bool
}
variable "eks_cluster_ip_family" {
  type = string
}
variable "eks_authentication_mode" {
  type = string
}
variable "eks_ami_id" {
  type = string
}
variable "eks_key_arn" {
  type = string
}
variable "eks_tags" {
  type = map(string)
}

variable "eks_cluster_endpoint_private_access" {
  type = bool
}
variable "eks_nodegroup_key_name_app" {
  type = string
}
variable "eks_nodegroup_key_name_service" {
  type = string
}
variable "cluster_enabled_log_types" {
  type = list(string)
}
variable "cloud_provider" {
  type = string
}

### APPLICATION-NG
variable "app_instance_type" {
  type = list(string)
}
variable "app_ebs_volume_type" {
  type = string
}
variable "app_ebs_volume_size" {
  type = number
}


### SERVICE-NG
variable "service_instance_type" {
  type = list(string)
}
variable "service_ebs_volume_type" {
  type = string
}
variable "service_ebs_volume_size" {
  type = number
}

##############################
# EKS Addons
##############################
variable "aws_lbc_role" {
  type        = string
  description = "Name of IAM role for the Service Account of AWS LB Controller"
}
variable "ca_role" {
  type        = string
  description = "Name of IAM role for the Service Account of Cluster Autoscaler"
}
variable "metric_server_role" {
  type        = string
  description = "Name of IAM role for the Service Account of Metrics Server"
}


########################################################################
# RDS
########################################################################

variable "rds_subnet_group_name" {
  type = string
}

variable "rds_subnet_group_tags" {
  type = map(string)
}


variable "rds_identifier" {
  type = string
}

variable "rds_instanceType" {
  type = string
}


variable "rds_engine_lifecycle_support" {
  type = string
}
variable "rds_parameter_group_name" {
  type = string
}

variable "rds_option_group_name" {
  type = string
}

variable "rds_options_group_major_engine_version" {
  type = string
}

variable "rds_parameter_group_family" {
  type = string
}

variable "rds_engine" {
  type = string
}

variable "rds_engine_version" {
  type = string
}

variable "rds_storage_type" {
  type = string
}

variable "rds_allocated_storage" {
  type = string
}

variable "rds_max_allocated_storage" {
  type = string
}

variable "rds_storage_encrypted" {
  type = bool
}

variable "rds_kms_key_id" {
  type = string
}
variable "rds_network_type" {
  type = string
}

variable "rds_db_name" {
  type = string
}

variable "rds_username" {
  type = string
}

variable "rds_password" {
  type = string
}
variable "rds_port" {
  type = string
}
variable "rds_availability_zone" {
  type = string
}
variable "rds_multi_az" {
  type = bool
}

variable "rds_publicly_accessible" {
  type = bool
}

variable "rds_tags" {
  type = map(string)
}

variable "rds_apply_immediately" {
  type = bool
}
variable "rds_auto_minor_version_upgrade" {
  type = bool
}

variable "rds_allow_major_version_upgrade" {
  type = bool
}
variable "rds_maintenance_window" {
  type = string
}
variable "rds_backup_retention_period" {
  type = string
}
variable "rds_backup_window" {
  type = string
}
variable "rds_delete_automated_backups" {
  type = bool
}
variable "rds_deletion_protection" {
  type = bool
}

variable "rds_ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "rds_egress_rules" {
  description = "List of egress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}
######################################
# ECR
######################################
variable "ecr_tags" {
  type = map(string)
}

variable "repository_names" {
  type = list(string)
}

variable "repository_type" {
  type        = string
  description = "Type os repository (public or private)"
}

variable "tag_mutability" {
  type        = string
  description = "This defines the mutability feature of tags"
}

variable "repository_force_delete" {
  type = bool
}




######################################
# EFS
######################################

# variable "shared_config_files" {
#   type = list(string)
# }

# variable "shared_credentials_files" {
#   type = list(string)
# }

# variable "profile" {
#   type = string
# }

########################################################################
# EFS
########################################################################
variable "efs_create" {
  type = bool
}

variable "efs_performance_mode" {
  type = string
}

variable "efs_encrypted" {
  type = bool
}

variable "efs_creation_token" {
  type = string
}

variable "efs_tags" {
  type = map(string)
}

variable "efs_throughput_mode" {
  type = string
}

variable "efs_create_backup_policy" {
  type = bool
}
variable "efs_enable_backup_policy" {
  type = bool
}
variable "efs_attach_policy" {
  type = bool
}
variable "efs_ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "efs_egress_rules" {
  description = "List of egress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}