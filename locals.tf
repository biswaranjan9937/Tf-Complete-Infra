################################################################################
# Common Locals
################################################################################
# locals {
#   environment = var.environment
# }

################################################################################
# VPC Module
################################################################################
locals {

  vpc_name = "${var.vpc_name}-${var.environment}"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3) ### Limiting to 3 AZs. If the region has less than 3 AZs, Terraform will error.
}

####################################################################
# KMS
####################################################################
locals {}

####################################################################
# PRITUNL
####################################################################
locals {
  ec2_pritunl_key_name          = var.ec2_pritunl_key_name
  ec2_pritunl_name              = "${var.Project_Name}-${var.environment}-${var.ec2_pritunl_name}"
  ec2_pritunl_iam_role_policies = var.ec2_pritunl_iam_role_policies
  ec2_pritunl_kms_key_id        = module.kms_complete.key_arn
  ec2_pritunl_ebs_block_devices = var.ec2_pritunl_ebs_block_devices
}


###################################################################
# ACM
###################################################################
locals {
  acm_main_tags = merge(var.acm_main_tags, { Name = var.main_domain_name })
}


####################################################################
# EKS
####################################################################
locals {
  # eks_vpc_private_subnets              = [module.vpc.private_subnets[0]]
  eks_vpc_private_controlPlane_subnets = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]
  eks_vpc_public_controlPlane_subnets  = [module.vpc.public_subnets[0], module.vpc.public_subnets[1], module.vpc.public_subnets[2]]
  eks_vpc_public_subnets               = [module.vpc.public_subnets[0], module.vpc.public_subnets[1], module.vpc.public_subnets[2]]
  # eks_vpc_cidr                         = module.vpc.vpc_cidr_block
  eks_app_node_role_ng     = "${var.eks_cluster_name}-${var.environment}-APPLICATION-NG-ROLE"
  eks_service_node_role_ng = "${var.eks_cluster_name}-${var.environment}-SERVICE-NG-ROLE"
  # eks_ami_id                = try(var.eks_ami_id, data.aws_ssm_parameter.al2023_ami_id.value)
  eks_key_arn                    = module.kms_complete.key_arn
  eks_nodegroup_key_name_app     = var.eks_nodegroup_key_name_app
  eks_nodegroup_key_name_service = var.eks_nodegroup_key_name_service

}
####################################################################
# RDS
####################################################################

locals {
  rds_subnet_group_name    = "${var.rds_subnet_group_name}-${var.environment}"
  rds_identifier           = "${var.rds_identifier}-${var.environment}-rds"
  rds_parameter_group_name = "${var.rds_parameter_group_name}-${var.environment}"
  rds_option_group_name    = "${var.rds_option_group_name}-${var.environment}"
}

####################################################################
# ECR
####################################################################
locals {
  ecr_kms_key_arn = module.kms_complete.key_arn
}


###################################
# EFS
################################
locals {
  efs_name = "${var.efs_name}-${var.environment}-efs"
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