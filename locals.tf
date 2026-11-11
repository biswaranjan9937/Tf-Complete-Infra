####################################
# VPC Module
####################################
locals {
  vpc_name = "${var.project_name}-${var.environment}"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3) ### Limiting to 3 AZs. If the region has less than 3 AZs, Terraform will error.
}

####################################################################
# PRITUNL
####################################################################
locals {
  ec2_pritunl_name = "${var.project_name}-${var.environment}-VPN"
  vpn_key_pair     = "${var.project_name}-${var.environment}-VPN-1b-KeyPair"
  # ec2_pritunl_iam_role_policies = var.ec2_pritunl_iam_role_policies
  # ec2_pritunl_ebs_block_devices = var.ec2_pritunl_ebs_block_devices
}

###################################################################
# KMS
###################################################################
locals {
  alias_name = ["${var.project_name}-${var.environment}-CMK"]
}
###################################################################
# ACM
###################################################################
# locals {
#   acm_main_tags = merge(var.acm_main_tags, { Name = var.main_domain_name, Environment = var.environment })
# }

############################################
# Route53
############################################
locals {
  #zone_name = sort(keys(module.zones.route53_zone_zone_id))[0]
  zone_tags = {
    "Implementedby" = "Wokrmates",
    "Managedby"     = "Workmates",
    "Layer"         = "DNS"
  }
}

####################################################################
# EKS
####################################################################
locals {
  eks_app_ng_key_name = "${var.project_name}-${var.environment}-EKS-App-NG-Key"
  eks_svc_ng_key_name = "${var.project_name}-${var.environment}-EKS-Svc-NG-Key"
  eks_mon_ng_key_name = "${var.project_name}-${var.environment}-EKS-Mon-NG-Key"
  app_ng_role_name    = "${var.project_name}-${var.environment}-EKS-Application-NG-Role"
  svc_ng_role_name    = "${var.project_name}-${var.environment}-EKS-Service-NG-Role"
  mon_ng_role_name    = "${var.project_name}-${var.environment}-EKS-Monitoring-NG-Role"
  # eks_key_arn         = module.aws_cmk.key_arn
  cluster_name        = "${var.project_name}-${var.environment}-EKS-Cluster"
  app_node_group_name = "${local.cluster_name}-Application-NG"
  svc_node_group_name = "${local.cluster_name}-Service-NG"
  mon_node_group_name = "${local.cluster_name}-Monitoring-NG"
}
####################################################################
# RDS
####################################################################

locals {
  rds_subnet_group_name    = lower("${var.project_name}-${var.environment}-subnet-group")
  rds_identifier           = lower("${var.project_name}-${var.environment}-${var.rds_identifier}")
  rds_parameter_group_name = lower("${var.project_name}-${var.environment}-parameter-group")
  rds_option_group_name    = lower("${var.project_name}-${var.environment}-option-group")
}

####################################################################
# ECR
####################################################################
locals {
  ecr_kms_key_arn = module.aws_cmk.key_arn
}


###################################
# EFS
################################
locals {
  efs_name = "${var.project_name}-${var.environment}-EFS"
  efs_azs  = slice(data.aws_availability_zones.available.names, 0, 3)
}


####################################################################
# ALB
# ####################################################################
# locals {
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