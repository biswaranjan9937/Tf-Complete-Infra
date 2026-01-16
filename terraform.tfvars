region_backend = "ap-south-2"
Project_Name   = "Innervex-Technologies"
########################################
# VPC
########################################
environment          = "PROD"
vpc_cidr             = "172.173.0.0/16"
region               = "ap-south-2"
vpc_name             = "Innervex-Technologies"
single_nat_gateway   = "true"
enable_nat_gateway   = "true"
enable_dns_hostnames = "true"
enable_dns_support   = "true"
vpc_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Environment"   = "PROD",
  "Project"       = "Innervex-Technologies"
  "Layer"         = "Gateway"
}
vpc_flowlog_bucket = "innervex-technologies-vpcflowlog"

########################################
# Pritunl
########################################
cred_bucketName = "innervex-technologies-credentials"
bucketTags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Environment"   = "PROD",
  "Project"       = "Innervex-Technologies"
  "Layer"         = "Storage"
}
ec2_pritunl_ami_id        = "ami-0c6ef28989b434b51"  
ec2_pritunl_instance_type = "t3.large"
ec2_pritunl_name          = "PRITUNL"
#ec2_pritunl_iam_role_name = "CWMManagedInstanceRole"
ec2_pritunl_volume_type = "gp3"
ec2_pritunl_volume_size = "20"
#ec2_pritunl_kms_key_id     = ""
ec2_pritunl_root_encrypted = true
ec2_pritunl_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Environment"   = "PROD",
  "Project"       = "Innervex-Technologies"
  "Layer"         = "Gateway"
}
ec2_pritunl_key_name               = "Innervex-Technologies-Pritunl-VPN-2b-keypair"
ec2_pritunl_termination_protection = true
ec2_pritunl_iam_instance_profile   = "CWMIAMROLE-InstanceProfile-KDvzcgT2Vw31"   
ec2_pritunl_ingress_rules = [
  {
    cidr_blocks = ["15.206.48.168/32"]
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  },
  {
    cidr_blocks = ["10.3.1.105/32"]
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  },
  {
    cidr_blocks = ["15.206.48.168/32"]
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
  },
  {
    cidr_blocks = ["10.3.1.105/32"]
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
  },
  {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 1557     #### pritunl port for udp
    protocol    = "udp"
    to_port     = 1557
  },
  {
    cidr_blocks = ["15.206.48.168/32"]
    from_port   = 2223     #### pritunl ssh port
    protocol    = "tcp"
    to_port     = 2223
  },
  {
    cidr_blocks = ["10.3.1.105/32"]
    from_port   = 2223     #### pritunl ssh port
    protocol    = "tcp"
    to_port     = 2223
  },

]
ec2_pritunl_egress_rules = [{
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 0
  protocol    = "-1"
  to_port     = 0
}]
########################################################################
# KMS
########################################################################
kms_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Environment"   = "PROD",
  "Project"       = "Innervex-Technologies"
  "Layer"         = "Security"
}
key_administrators_list = [
  "arn:aws:iam::187691954636:role/Workmates-SSO-AdminRole",
  "arn:aws:iam::187691954636:role/Workmates-SSO-L2SupportRole"
]
key_user_list = [
  "arn:aws:iam::187691954636:role/CWMManagedInstanceRole",
  "arn:aws:iam::187691954636:role/Workmates-SSO-AdminRole",
  "arn:aws:iam::187691954636:role/Workmates-SSO-L2SupportRole"
]
key_aliases                 = ["Innervex-Technologies-PROD-CMK"]
key_description             = "Innervex-Technologies PROD Customer managed Key"
key_deletion_window_in_days = 7
key_usage                   = "ENCRYPT_DECRYPT"
kms_region                  = "ap-south-2"
enable_multi_region         = false
enable_key_rotation         = false
enable_key                  = true


########################################################################
# ACM
########################################################################
# main_domain_name       = "revmigrate.com"
# create_route53_records = "true"
# validation_method      = "DNS"
# acm_main_tags = {
#   "Implementedby" = "Workmates",
#   "Managedby"     = "RevUpAI",
#   "Project"       = "RevUpAI"
#   "Environment"   = "PROD"
#   "Layer"         = "SSL"
# }

########################################
# EC2 - UAT
########################################
availability_zone = "ap-south-2b"
uat_ami_id        = "ami-09852e1dff5606dee"    
uat_instance_type = "m6a.2xlarge"
uat_name          = "Innervex-Technologies-UAT-App+DB-2b"
uat_volume_type   = "gp3"
uat_root_volume_size   = "300"
uat_ebs_volume_size   = "200"
uat_root_encrypted = true
uat_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Layer"         = "App+DB",
  "Environment"   = "UAT",
  "Project"       = "Innervex-Technologies"
}
uat_ec2_key_name               = "Innervex-Technologies-UAT-App+DB-2b-Keypair"
uat_termination_protection = true
uat_iam_instance_profile   = "CWMIAMROLE-InstanceProfile-KDvzcgT2Vw31"
uat_ingress_rules = [
  {
    cidr_blocks = ["172.173.0.0/16"]
    from_port   = 2223
    protocol    = "tcp"
    to_port     = 2223
  },
  {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }
]
uat_egress_rules = [{
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 0
  protocol    = "-1"
  to_port     = 0
}]


########################################
# EC2 - PROD
########################################
# availability_zone = "ap-south-2b"
prod_ami_id        = "ami-09852e1dff5606dee"    
prod_instance_type = "r6a.4xlarge"
prod_name          = "Innervex-Technologies-PROD-App+DB-2b"
prod_volume_type   = "gp3"
prod_root_volume_size   = "300"
prod_ebs_volume_size   = "200"
prod_root_encrypted = true
prod_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Layer"         = "App+DB",
  "Environment"   = "PROD",
  "Project"       = "Innervex-Technologies"
}
prod_ec2_key_name               = "Innervex-Technologies-PROD-App+DB-2b-Keypair"
prod_termination_protection = true
prod_iam_instance_profile   = "CWMIAMROLE-InstanceProfile-KDvzcgT2Vw31"
prod_ingress_rules = [
  {
    cidr_blocks = ["172.173.0.0/16"]
    from_port   = 2223
    protocol    = "tcp"
    to_port     = 2223
  },
  {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }
]
prod_egress_rules = [{
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 0
  protocol    = "-1"
  to_port     = 0
}]



#########################################################################
# ALB
#########################################################################
alb_sg_name = "Innervex-Technologies-ALB-SG"
alb_name    = "Innervex-Technologies-alb"
uat_ec2_tg_name = "Innervex-Technologies-UAT-TG-80"
alb_access_logs_s3_bucket = "innervex-technologies-alb-access-logs"
alb_access_logs_s3_prefix = "uat-alb-logs"

########################################
# S3 Buckets
########################################
uat_s3_bucket_name  = "innervex-technologies-uat-bucket"
prod_s3_bucket_name = "innervex-technologies-prod-bucket"

########################################
# Budget
########################################
budget_amount = "801"
# anomaly_threshold = "27"