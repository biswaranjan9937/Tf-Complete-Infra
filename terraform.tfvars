project_name = "Project"
########################################
# VPC
########################################
environment           = "UAT"
vpc_cidr              = "172.16.0.0/16"
region                = "ap-south-1"
single_nat_gateway    = "true"
enable_nat_gateway    = "true"
enable_dns_hostnames  = "true"
enable_dns_resolution = "true"
vpc_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Layer"         = "Gateway"
}
vpc_flowlog_bucket = "project-prod-vpcflowlog-bucket"

########################################
# Pritunl
########################################
cred_bucketName                         = "project-uat-creds-bucket"
ec2_pritunl_ami_id                      = "ami-035827357e3c7e810" ### AL2023 of ap-south-1
ec2_pritunl_instance_type               = "t3.medium"
ec2_pritunl_volume_type                 = "gp3"
ec2_pritunl_volume_size                 = "25"
ec2_pritunl_root_encrypted              = true
ec2_pritunl_additional_volume_type      = "gp3"
ec2_pritunl_additional_volume_size      = "10"
ec2_pritunl_additional_volume_encrypted = true

ec2_pritunl_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Layer"         = "Gateway",
  "wm_backup"     = "yes",
  "dlcm"          = "no"
}

ec2_pritunl_key_name               = "Project-UAT-VPN-1b-keypair"
ec2_pritunl_termination_protection = false
ec2_pritunl_iam_instance_profile   = "ssm-role" ### This IAM Instance Profile has SSM and Read Only access.

ec2_pritunl_ingress_rules = [
  # {
  #   cidr_blocks = ["15.206.48.168/32"] ### workmates public ip
  #   from_port   = 80
  #   protocol    = "tcp"
  #   to_port     = 80
  # },
  # {
  #   cidr_blocks = ["10.3.1.105/32"] ### workmates private ip
  #   from_port   = 80
  #   protocol    = "tcp"
  #   to_port     = 80
  # },
  {
    cidr_blocks = ["15.206.48.168/32"]
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
  },
  # {
  #   cidr_blocks = ["10.3.1.105/32"]
  #   from_port   = 443
  #   protocol    = "tcp"
  #   to_port     = 443
  # },
  # {
  #   cidr_blocks = ["59.144.30.58/32"] #### workmates publicInternet IP
  #   from_port   = 443
  #   protocol    = "tcp"
  #   to_port     = 443
  # },
  {
    cidr_blocks = ["15.206.48.168/32"]
    from_port   = 2223 #### pritunl ssh port
    protocol    = "tcp"
    to_port     = 2223
  },
  # {
  #   cidr_blocks = ["10.3.1.105/32"]
  #   from_port   = 2223 #### pritunl ssh port
  #   protocol    = "tcp"
  #   to_port     = 2223
  # },
  {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 1557 #### pritunl server port for udp
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
key_description             = "Project Customer Managed Key"
key_deletion_window_in_days = 30
key_usage                   = "ENCRYPT_DECRYPT"
kms_region                  = "ap-south-1"
enable_multi_region         = false
enable_key_rotation         = true
enable_key                  = true

########################################################################
# ACM
########################################################################
main_domain_name       = "seawhale.in"
create_route53_records = "true"
validate_certificate   = "true" ### Certificate validation will be done automatically by Terraform if you set create_route53_records to true. If you set create_route53_records to false, you need to validate the certificate manually from AWS console or CLI.
validation_method      = "DNS"  ### Supports Email and DNS. DNS is recommended.
acm_main_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Layer"         = "SSL"
}


########################################################################
# EKS
########################################################################
eks_cluster_version                 = "1.36"
eks_cluster_endpoint_public_access  = "true"
eks_cluster_endpoint_private_access = "true"
eks_cluster_ip_family               = "ipv4"
cluster_enabled_log_types = [
  "api",
  "audit",
  "authenticator",
  "controllerManager",
  "scheduler"
]
eks_authentication_mode = "API_AND_CONFIG_MAP"


# eks_app_ng_key_name = "Project-APP-Node-Key" #### Need to be created first.
# eks_svc_ng_key_name = "Project-Services-Node-Key"
# eks_mon_ng_key_name = "Project-Monitoring-Node-Key"
eks_ami_id = "" #ami-0f79d8d8f8d504808

cloud_provider = "aws"

eks_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Layer"         = "Kubernetes"
}

### APPLICATION NODE GROUP
app_ng_min_size        = 0
app_ng_max_size        = 1
app_ng_desired_size    = 0
app_ng_instance_type   = ["t3.medium"]
app_ng_ebs_volume_type = "gp3"
app_ng_ebs_volume_size = 20

### SERVICES NODE GROUP
svc_ng_min_size        = 1
svc_ng_max_size        = 2
svc_ng_desired_size    = 1
svc_ng_instance_type   = ["t3.medium"]
svc_ng_ebs_volume_type = "gp3"
svc_ng_ebs_volume_size = 20

### Monitoring NODE GROUP
mon_ng_min_size        = 1
mon_ng_max_size        = 2
mon_ng_desired_size    = 1
mon_ng_instance_type   = ["t3.medium"]
mon_ng_ebs_volume_type = "gp3"
mon_ng_ebs_volume_size = 20

############################
# EKS Addons
############################
aws_lbc_role       = "AWS-LB-CONTROLLER-ROLE"
ca_role            = "EKS-CLUSTER-AUTOSCALER-ROLE"
metric_server_role = "EKS-METRICS-SERVER-ROLE"

########################################################################
# RDS
########################################################################
rds_identifier                         = "PostgreSQL"
rds_snapshot_identifier                = "arn:aws:rds:ap-south-1:239861161507:snapshot:rds-preprod-2026-07-07-12-36-ist-copy-using-cmk-v1"
rds_instanceType                       = "db.t4g.medium"
rds_parameter_group_family             = "postgres15"
rds_options_group_major_engine_version = "15"
rds_engine                             = "postgres"
rds_engine_version                     = "15.17"
rds_engine_lifecycle_support           = "open-source-rds-extended-support-disabled"
rds_storage_type                       = "gp3"
rds_allocated_storage                  = "130"
rds_max_allocated_storage              = "0"
rds_storage_encrypted                  = true
rds_kms_key_id                         = ""
rds_network_type                       = "IPV4"
rds_db_name                            = ""
rds_username                           = "postgres"
rds_password                           = "hycnWesdOirutj"
rds_port                               = "5444"
rds_multi_az                           = false
rds_publicly_accessible                = false
rds_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Layer"         = "Database"
}
rds_apply_immediately           = true
rds_auto_minor_version_upgrade  = false
rds_allow_major_version_upgrade = false
rds_maintenance_window          = "Mon:00:00-Mon:03:00"
rds_backup_retention_period     = "7"
rds_backup_window               = "09:30-10:30"
rds_delete_automated_backups    = true
rds_deletion_protection         = false
parameters = [
  {
    name         = "timezone"
    value        = "Asia/Kolkata"
    apply_method = "immediate"
  }
]

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
repository_names = [
  "frontend_repo",
  "backend_repo"
]

repository_type         = "private" # It can be public or private.
tag_mutability          = "MUTABLE" # It can be IMMUTABLE or MUTABLE.
repository_force_delete = true

ecr_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Layer"         = "Container_Registry"
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
efs_throughput_mode      = "elastic"

efs_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Layer"         = "EFS"
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
  "Layer"         = "Storage"
}

########################################
# Budget
########################################
# budget_amount = "801"
# anomaly_threshold = "27"
