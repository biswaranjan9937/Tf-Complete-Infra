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
  type = string
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
# variable "main_domain_name" {
#   type = string
# }

# variable "create_route53_records" {
#   type = bool
# }

# variable "validation_method" {
#   type = string
# }

# variable "acm_main_tags" {
#   type = map(string)
# }


########################################################################
# EC2 - UAT
########################################################################
variable "availability_zone" {
  type = string
}

variable "uat_ec2_key_name" {
  type = string
}
variable "uat_ami_id" {
  type = string
}
variable "uat_instance_type" {
  type = string
}
variable "uat_name" {
  type = string
}
variable "uat_iam_role_policies" {
  type    = map(string)
  default = {}
}
variable "uat_volume_type" {
  type = string
}
variable "uat_volume_size" {
  type = string
}
variable "uat_root_encrypted" {
  type = bool
}
variable "uat_ebs_block_devices" {
  type    = list(any)
  default = []
}
variable "uat_tags" {
  type = map(string)
}
variable "uat_termination_protection" {
  type = bool
}
variable "uat_iam_instance_profile" {
  type = string
}
variable "uat_ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
} 

variable "uat_egress_rules" {
  description = "List of egress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}     


########################################################################
# EC2 - PROD
########################################################################

variable "prod_ec2_key_name" {
  type = string
}
variable "prod_ami_id" {
  type = string
}
variable "prod_instance_type" {
  type = string
}
variable "prod_name" {
  type = string
}
variable "prod_iam_role_policies" {
  type    = map(string)
  default = {}
}
variable "prod_volume_type" {
  type = string
}
variable "prod_volume_size" {
  type = string
}
variable "prod_root_encrypted" {
  type = bool
}
variable "prod_ebs_block_devices" {
  type    = list(any)
  default = []
}
variable "prod_tags" {
  type = map(string)
}
variable "prod_termination_protection" {
  type = bool
}
variable "prod_iam_instance_profile" {
  type = string
}
variable "prod_ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
} 

variable "prod_egress_rules" {
  description = "List of egress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
} 


########################################################################
# ALB
########################################################################
variable "alb_sg_name" {
  type = string
}
variable "alb_name" {
  type = string
}
variable "uat_ec2_tg_name" {
  type = string
}
variable "alb_access_logs_s3_bucket" {
  type = string
}
variable "alb_access_logs_s3_prefix" {
  type = string
}


########################################################################
# S3
########################################################################
variable "uat_s3_bucket_name" {
  type = string
}
variable "prod_s3_bucket_name" {
  type = string
}

################################
# Budget
################################
variable "budget_amount" {
  description = "Monthly budget amount in USD"
  type        = string
}

variable "anomaly_threshold" {
  description = "Threshold for cost anomaly detection"
  type        = string
}