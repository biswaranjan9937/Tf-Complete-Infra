# region_backend = "ap-south-1"
Project_Name   = "Project"
########################################
# VPC
########################################
environment          = "UAT"
vpc_cidr             = "172.16.0.0/16"
region               = "ap-south-1"
# vpc_name             = "project"
single_nat_gateway   = "true"
enable_nat_gateway   = "true"
enable_dns_hostnames = "true"
enable_dns_support   = "true"
vpc_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Environment"   = "UAT",
  "Project"       = "project"
  "Layer"         = "Gateway"
}
vpc_flowlog_bucket = "project-prod-vpcflowlog7894"

########################################
# Pritunl
########################################
pritunl_availability_zone      = "ap-south-1b"
cred_bucketName = "project-prod-pritunl-creds7894"
ec2_pritunl_ami_id        = "ami-0388e3ada3d9812da" ### ubuntu 24.04 of ap-south-1
ec2_pritunl_instance_type = "t3.medium"
ec2_pritunl_volume_type = "gp3"
ec2_pritunl_volume_size = "25"
ec2_pritunl_root_encrypted = true

ec2_pritunl_additional_volume_type = "gp3"
ec2_pritunl_additional_volume_size = "25"
ec2_pritunl_additional_volume_encrypted = true
ec2_pritunl_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Environment"   = "UAT",
  "Project"       = "project",
  "Layer"         = "Gateway"
}
ec2_pritunl_key_name               = "Project-UAT-VPN-1b-keypair"
ec2_pritunl_termination_protection = false
ec2_pritunl_iam_instance_profile   = "CWMIAMROLE-InstanceProfile-rEMu7z8991ZX" ### This IAM Instance Profile has SSM and Read Only access.
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
    cidr_blocks = ["59.144.30.58/32"] #### workmates publicInternet IP
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
  },
  {
    cidr_blocks = ["15.206.48.168/32"]
    from_port   = 2223                #### pritunl ssh port
    protocol    = "tcp"
    to_port     = 2223
  },
  {
    cidr_blocks = ["10.3.1.105/32"]
    from_port   = 2223                #### pritunl ssh port
    protocol    = "tcp"
    to_port     = 2223
  },
  {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 1557                #### pritunl server port for udp
    protocol    = "udp"
    to_port     = 1557
  }
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
  "Environment"   = "UAT",
  "Project"       = "Project",
  "Layer"         = "Security"
}
key_administrators_list = [ ### IAM roles or users who can manage the key
  "arn:aws:iam::675169529857:role/Workmates-SSO-AdminRole",
  "arn:aws:iam::675169529857:role/Workmates-SSO-L2SupportRole"
]
key_user_list = [ ### IAM roles or users who can use the key for encryption/decryption
  "arn:aws:iam::675169529857:role/CWMManagedInstanceRole",
  "arn:aws:iam::675169529857:role/Workmates-SSO-AdminRole",
  "arn:aws:iam::675169529857:role/Workmates-SSO-L2SupportRole"
]
key_aliases                 = ["project-prod-CMK"]
key_description             = "Project Customer Managed Key"
key_deletion_window_in_days = 7
key_usage                   = "ENCRYPT_DECRYPT"
kms_region                  = "ap-south-1"
enable_multi_region         = false
enable_key_rotation         = false
enable_key                  = true

########################################################################
# ACM
########################################################################
main_domain_name       = "devopskolkata.org"
create_route53_records = "true" 
validation_method      = "DNS"  ### Supports Email and DNS. DNS is recommended.
acm_main_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Project"       = "Project",
  "Environment"   = "UAT",
  "Layer"         = "SSL"
}


########################################################################
# EKS
########################################################################
eks_cluster_name                    = "POC-cluster"
eks_cluster_version                 = "1.34"
eks_ami_id                          = "" #ami-0f79d8d8f8d504808
eks_cluster_endpoint_public_access  = "true"
eks_cluster_endpoint_private_access = "false"
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
  "Environment"   = "UAT",
  "Project"       = "Project"
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
rds_subnet_group_name = "project-uat-rds-subnet-grp"
rds_subnet_group_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Environment"   = "UAT",
  "Layer"         = "Database",
  "Project"       = "Project"
}

rds_identifier                         = "Project-PostgreSQL"
rds_instanceType                       = "db.t4g.medium"
rds_parameter_group_name               = "project-uat-postgres-parameter-grp"
rds_parameter_group_family             = "postgres17"
rds_option_group_name                  = "project-uat-postgres-options-grp"
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
rds_availability_zone                  = "ap-south-1b"
rds_multi_az                           = false
rds_publicly_accessible                = false
rds_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Environment"   = "UAT",
  "Layer"         = "Database",
  "Project"       = "Project",
}
rds_apply_immediately           = true
rds_auto_minor_version_upgrade  = false
rds_allow_major_version_upgrade = false
rds_maintenance_window          = "Mon:00:00-Mon:03:00"
rds_backup_retention_period     = "7"
rds_backup_window               = "09:30-10:30"
rds_delete_automated_backups    = true
rds_deletion_protection         = true
rds_ingress_rules = [
  {
    from_port   = 5444
    to_port     = 5444
    protocol    = "tcp"
    cidr_blocks = ["172.16.0.0/16"]
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
  "frontend_repo",
  "backend_repo"
]

ecr_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Environment"   = "UAT",
  "Layer"         = "Storage",
  "Project"       = "Project"
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
efs_creation_token       = "Project-Uat"
efs_throughput_mode      = "bursting"
efs_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Layer"         = "Storage",
  "Env"           = "UAT",
  "Project"       = "Project"
}
efs_ingress_rules = [
  {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["172.16.0.0/16"] ### VPC CIDR.
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
bucketTags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Environment"   = "UAT",
  "Project"       = "project"
  "Layer"         = "Storage"
}

########################################
# Budget
########################################
# budget_amount = "801"
# anomaly_threshold = "27"