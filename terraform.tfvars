region_backend = "ap-south-1"
Project_Name   = "project"
########################################
# VPC
########################################
environment          = "prod"
vpc_cidr             = "172.173.0.0/16"
region               = "ap-south-1"
vpc_name             = "project-prod-vpc"
single_nat_gateway   = "true"
enable_nat_gateway   = "true"
enable_dns_hostnames = "true"
enable_dns_support   = "true"
vpc_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Environment"   = "PROD",
  "Project"       = "project"
  "Layer"         = "Gateway"
}
vpc_flowlog_bucket = "project-prod-vpcflowlog"

########################################
# Pritunl
########################################
cred_bucketName = "project-prod-pritunl-creds"
bucketTags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Environment"   = "PROD",
  "Project"       = "project"
  "Layer"         = "Storage"
}
ec2_pritunl_ami_id        = "ami-019715e0d74f695be" ### ubuntu 24.04 of ap-south-1
ec2_pritunl_instance_type = "t3.micro"
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
  "Project"       = "project",
  "Layer"         = "Gateway"
}
ec2_pritunl_key_name               = "project-Pritunl-VPN-1a-keypair"
ec2_pritunl_termination_protection = false
# ec2_pritunl_iam_instance_profile   = "CWMIAMROLE-InstanceProfile-KDvzcgT2Vw31" ### This IAM Instance Profile has SSM and Read Only access.
ec2_pritunl_ingress_rules = [
  {
    cidr_blocks = ["15.206.48.168/32"] ### workmates public ip
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  },
  {
    cidr_blocks = ["10.3.1.105/32"] ### workmates private ip
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
    cidr_blocks = ["59.144.30.58/32"] ## workmates publicInternet IP
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
  },
  {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 1557 ### pritunl server port for udp
    protocol    = "udp"
    to_port     = 1557
  },
  {
    cidr_blocks = ["15.206.48.168/32"]
    from_port   = 2223 ### pritunl ssh port
    protocol    = "tcp"
    to_port     = 2223
  },
  {
    cidr_blocks = ["10.3.1.105/32"]
    from_port   = 2223 #### pritunl ssh port
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
  "Project"       = "project"
  "Layer"         = "Security"
}
key_administrators_list = [ ### IAM roles or users who can manage the key
  "arn:aws:iam::187691954636:role/Workmates-SSO-AdminRole",
  "arn:aws:iam::187691954636:role/Workmates-SSO-L2SupportRole"
]
key_user_list = [ ### IAM roles or users who can use the key for encryption/decryption
  "arn:aws:iam::187691954636:role/CWMManagedInstanceRole",
  "arn:aws:iam::187691954636:role/Workmates-SSO-AdminRole",
  "arn:aws:iam::187691954636:role/Workmates-SSO-L2SupportRole"
]
key_aliases                 = ["project-prod-CMK"]
key_description             = "project prod Customer managed Key"
key_deletion_window_in_days = 7
key_usage                   = "ENCRYPT_DECRYPT"
kms_region                  = "ap-south-1"
enable_multi_region         = false
enable_key_rotation         = false
enable_key                  = true

########################################################################
# ACM
########################################################################
main_domain_name       = "biswa.click"
create_route53_records = "false" ### Need to do this manually.
validation_method      = "DNS"   ### Supports Email and DNS. DNS is recommended.
acm_main_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Project"       = "project"
  "Environment"   = "PROD"
  "Layer"         = "SSL"
}


########################################################################
# EKS
########################################################################
eks_cluster_name                    = "POC"
eks_cluster_version                 = "1.34"
eks_ami_id                          = "" #ami-0f79d8d8f8d504808
eks_cluster_endpoint_public_access  = "false"
eks_cluster_endpoint_private_access = "true"
eks_cluster_ip_family               = "ipv4"
eks_authentication_mode             = "API_AND_CONFIG_MAP"
eks_key_arn                         = ""
cluster_enabled_log_types = [
  "api",
  "audit",
  "authenticator",
  "controllerManager",
  "scheduler"
]

eks_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Environment"   = "PROD",
  "Project"       = "project"
  "Layer"         = "Kubernetes"
}

eks_nodegroup_key_name_app     = "project-APP-NG-Keypair" #### Need to be created first.
eks_nodegroup_key_name_service = "project-Services-NG-Keypair"
cloud_provider                 = "aws"

### APPLICATION NODE GROUP
app_instance_type   = ["t3.medium"]
app_ebs_volume_type = "gp3"
app_ebs_volume_size = 20

### SERVICES NODE GROUP
service_instance_type   = ["t3.medium"]
service_ebs_volume_type = "gp3"
service_ebs_volume_size = 20

############################
# EKS Addons
############################
aws_lbc_role       = "AWS-LB-CONTROLLER-ROLE"
ca_role            = "EKS-CLUSTER-AUTOSCALER-ROLE"
metric_server_role = "EKS-METRICS-SERVER-ROLE"

########################################################################
# RDS
########################################################################
rds_subnet_group_name = "project-prod-rds-subnet-grp"
rds_subnet_group_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Environment"   = "PROD",
  "Layer"         = "DB"
  "Project"       = "project"
}

rds_identifier                         = "project"
rds_instanceType                       = "db.t4g.medium"
rds_parameter_group_name               = "project-postgres-parameter-grp"
rds_parameter_group_family             = "postgres17"
rds_option_group_name                  = "project-postgres-options-grp"
rds_options_group_major_engine_version = "17"
rds_engine                             = "postgres"
rds_engine_version                     = "17"
rds_engine_lifecycle_support           = "open-source-rds-extended-support-disabled"
rds_storage_type                       = "gp3"
rds_allocated_storage                  = "30"
rds_max_allocated_storage              = "0"
rds_storage_encrypted                  = true
rds_kms_key_id                         = ""
rds_network_type                       = "IPV4"
rds_db_name                            = ""
rds_username                           = "postgres"
rds_password                           = "hycnWesdOirutj"
rds_port                               = "5444"
rds_availability_zone                  = "ap-south-1a"
rds_multi_az                           = false
rds_publicly_accessible                = false
rds_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Environment"   = "PROD",
  "Layer"         = "DB",
  "Project"       = "project",
  "Dev-RDS"       = "Auto-Shutdown"
}
rds_apply_immediately           = true
rds_auto_minor_version_upgrade  = false
rds_allow_major_version_upgrade = false
rds_maintenance_window          = "Mon:00:00-Mon:03:00"
rds_backup_retention_period     = "7"
rds_backup_window               = "09:30-10:30"
rds_delete_automated_backups    = true
rds_deletion_protection         = false
rds_ingress_rules = [
  {
    from_port   = 5444
    to_port     = 5444
    protocol    = "tcp"
    cidr_blocks = ["10.180.0.0/20"]
  }
]

rds_egress_rules = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

########################################################################
# ECR
########################################################################
repository_type         = "private" # It can be public or private.
tag_mutability          = "MUTABLE" # It can be IMMUTABLE or MUTABLE.
repository_force_delete = true

repository_names = [
  "project-prod-gateway-service",
  "project-prod-loan-request-service",
  "project-prod-master-data-service",
  "project-prod-asset-service"
]

ecr_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Environment"   = "PROD",
  "Layer"         = "Storage",
  "Project"       = "project"
}


##################################
# EFS
##################################
efs_create               = true
efs_create_backup_policy = false
efs_enable_backup_policy = false
efs_attach_policy        = false
efs_performance_mode     = "generalPurpose"
efs_encrypted            = true
efs_creation_token       = "project-Prod"
efs_throughput_mode      = "bursting"
efs_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Layer"         = "Storage",
  "Env"           = "PROD",
  "Project"       = "project"
}
efs_ingress_rules = [
  {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["172.173.0.0/16"] ### VPC CIDR.
  }
]

efs_egress_rules = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]



########################################
# EC2 - UAT
########################################
# availability_zone = "ap-south-2b"
# uat_ami_id        = "ami-09852e1dff5606dee"    
# uat_instance_type = "m6a.2xlarge"
# uat_name          = "project-UAT-App+DB-2b"
# uat_volume_type   = "gp3"
# uat_root_volume_size   = "300"
# uat_ebs_volume_size   = "200"
# uat_root_encrypted = true
# uat_tags = {
#   "Implementedby" = "Workmates",
#   "Managedby"     = "Workmates",
#   "Layer"         = "App+DB",
#   "Environment"   = "UAT",
#   "Project"       = "project"
# }
# uat_ec2_key_name               = "project-UAT-App+DB-2b-Keypair"
# uat_termination_protection = true
# uat_iam_instance_profile   = "CWMIAMROLE-InstanceProfile-KDvzcgT2Vw31"
# uat_ingress_rules = [
#   {
#     cidr_blocks = ["172.173.0.0/16"]
#     from_port   = 2223
#     protocol    = "tcp"
#     to_port     = 2223
#   },
#   {
#     cidr_blocks = ["0.0.0.0/0"]
#     from_port   = 22
#     protocol    = "tcp"
#     to_port     = 22
#   }
# ]
# uat_egress_rules = [{
#   cidr_blocks = ["0.0.0.0/0"]
#   from_port   = 0
#   protocol    = "-1"
#   to_port     = 0
# }]


########################################
# EC2 - PROD
########################################
# availability_zone = "ap-south-2b"
# prod_ami_id        = "ami-09852e1dff5606dee"    
# prod_instance_type = "r6a.4xlarge"
# prod_name          = "project-PROD-App+DB-2b"
# prod_volume_type   = "gp3"
# prod_root_volume_size   = "300"
# prod_ebs_volume_size   = "200"
# prod_root_encrypted = true
# prod_tags = {
#   "Implementedby" = "Workmates",
#   "Managedby"     = "Workmates",
#   "Layer"         = "App+DB",
#   "Environment"   = "PROD",
#   "Project"       = "project"
# }
# prod_ec2_key_name               = "project-PROD-App+DB-2b-Keypair"
# prod_termination_protection = true
# prod_iam_instance_profile   = "CWMIAMROLE-InstanceProfile-KDvzcgT2Vw31"
# prod_ingress_rules = [
#   {
#     cidr_blocks = ["172.173.0.0/16"]
#     from_port   = 2223
#     protocol    = "tcp"
#     to_port     = 2223
#   },
#   {
#     cidr_blocks = ["0.0.0.0/0"]
#     from_port   = 22
#     protocol    = "tcp"
#     to_port     = 22
#   }
# ]
# prod_egress_rules = [{
#   cidr_blocks = ["0.0.0.0/0"]
#   from_port   = 0
#   protocol    = "-1"
#   to_port     = 0
# }]



#########################################################################
# ALB
#########################################################################
# alb_sg_name = "project-ALB-SG"
# alb_name    = "project-alb"
# uat_ec2_tg_name = "project-UAT-TG-80"
# alb_access_logs_s3_bucket = "project-alb-access-logs"
# alb_access_logs_s3_prefix = "uat-alb-logs"

########################################
# S3 Buckets
########################################
# uat_s3_bucket_name  = "project-uat-bucket"
# prod_s3_bucket_name = "project-prod-bucket"

########################################
# Budget
########################################
# budget_amount = "801"
# anomaly_threshold = "27"