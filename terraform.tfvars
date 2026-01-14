region_backend = "ap-south-1"
########################################
# VPC
########################################
environment          = "PROD"
vpc_cidr             = "10.181.0.0/16"
region               = "ap-south-1"
vpc_name             = "CWM-Talent-Talker"
single_nat_gateway   = "true"
enable_nat_gateway   = "true"
enable_dns_hostnames = "true"
enable_dns_support   = "true"
vpc_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Environment"   = "PROD",
  "Project"       = "CWM-Talent-Talker"
  "Layer"         = "Gateway"
}
vpc_flowlog_bucket = "cwm-talent-talker-vpcflowlog"

########################################
# Pritunl
########################################
cred_bucketName = "cwm-prod-credentials"
bucketTags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Environment"   = "PROD",
  "Project"       = "CWM-Talent-Talker"
  "Layer"         = "Storage"
}
ec2_pritunl_ami_id        = "ami-021a584b49225376d"
ec2_pritunl_instance_type = "t3a.small"
ec2_pritunl_name          = "PRITUNL"
#ec2_pritunl_iam_role_name = "CWMManagedInstanceRole"
ec2_pritunl_volume_type = "gp3"
ec2_pritunl_volume_size = "30"
#ec2_pritunl_kms_key_id     = ""
ec2_pritunl_root_encrypted = true
ec2_pritunl_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Environment"   = "PROD",
  "Project"       = "CWM-Talent-Talker"
  "Layer"         = "Gateway"
}
ec2_pritunl_key_name               = "CWM-Pritunl-VPN-1b-keypair"
ec2_pritunl_termination_protection = true
ec2_pritunl_iam_instance_profile   = "CWMIAMROLE-InstanceProfile-rEMu7z8991ZX"
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
    from_port   = 1557
    protocol    = "udp"
    to_port     = 1557
  },
  {
    cidr_blocks = ["15.206.48.168/32"]
    from_port   = 2223
    protocol    = "tcp"
    to_port     = 2223
  },
  {
    cidr_blocks = ["10.3.1.105/32"]
    from_port   = 2223
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
  "Project"       = "CWM-Talent-Talker"
  "Layer"         = "Security"
}
key_administrators_list = [
  "arn:aws:iam::675169529857:role/Workmates-SSO-AdminRole",
  "arn:aws:iam::675169529857:role/Workmates-SSO-L2SupportRole"
]
key_user_list = [
  "arn:aws:iam::675169529857:role/CWMManagedInstanceRole",
  "arn:aws:iam::675169529857:role/Workmates-SSO-AdminRole",
  "arn:aws:iam::675169529857:role/Workmates-SSO-L2SupportRole",
  "arn:aws:iam::675169529857:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
  "arn:aws:iam::675169529857:role/CWM-Talent-Talker-ECS-Node-Role"
]
key_aliases                 = ["CWM-PROD-CMK"]
key_description             = "CWM PROD Customer managed Key"
key_deletion_window_in_days = 7
key_usage                   = "ENCRYPT_DECRYPT"
kms_region                  = "ap-south-1"
enable_multi_region         = false
enable_key_rotation         = false
enable_key                  = true


########################################################################
# RDS
########################################################################
rds_subnet_group_name = "cwm-talent-talker-prod-rds-subnet-grp"
rds_subnet_group_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Environment"   = "PROD",
  "Layer"         = "DB"
  "Project"       = "CWM-Talent-Talker"
}

rds_identifier                         = "cwm-talent-talker-prod-rds"
rds_instanceType                       = "db.t4g.small"
rds_parameter_group_name               = "cwm-talent-talker-postgres-parameter-grp"
rds_option_group_name                  = "cwm-talent-talker-postgres-options-grp"
rds_options_group_major_engine_version = "17"
rds_parameter_group_family             = "postgres17"
rds_engine                             = "postgres"
rds_engine_version                     = "17"
rds_engine_lifecycle_support           = "open-source-rds-extended-support-disabled"
rds_storage_type                       = "gp3"
rds_allocated_storage                  = "20"
rds_max_allocated_storage              = "50"
rds_storage_encrypted                  = true
rds_kms_key_id                         = ""
rds_network_type                       = "IPV4"
rds_db_name                            = ""
rds_username                           = "postgres"
rds_password                           = "jjUdhweoiasdbGdIUUd"
rds_port                               = "5444"
rds_availability_zone                  = "ap-south-1a"
rds_multi_az                           = false
rds_publicly_accessible                = false
rds_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Environment"   = "PROD",
  "Layer"         = "DB",
  "Project"       = "CWM-Talent-Talker"
}
rds_apply_immediately           = true
rds_auto_minor_version_upgrade  = false
rds_allow_major_version_upgrade = false
rds_maintenance_window          = "Mon:00:00-Mon:03:00"
rds_backup_retention_period     = "7"
rds_backup_window               = "09:30-10:30"
rds_delete_automated_backups    = true
rds_deletion_protection         = false
#rds_snapshot_identifier         = "CWM-PROD-CMK"
rds_ingress_rules = [
  {
    from_port   = 5444
    to_port     = 5444
    protocol    = "tcp"
    cidr_blocks = ["10.181.0.0/20"]
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
########################################################################
# R53
########################################################################
# zone_tags = {
#   "Implementedby" = "Workmates",
#   "Managedby"     = "RevUpAI",
#   "Project"       = "RevUpAI"
#   "Environment"   = "PROD"
#   "Layer"         = "DNS"
# }
########################################################################
# ECS Cluster
########################################################################
ecs_cluster_name = "CWM-Talent-Talker"
ecs_cluster_settings = [
  {
    name  = "containerInsights"
    value = "disabled"
  }
]

ecs_cluster_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Layer"         = "App"
  "Environment"   = "PROD",
  "Project"       = "CWM-Talent-Talker"
}

########################################################################
# ASG for ECS
########################################################################
asg_name = "CWM-Talent-Talker-PROD-ECS-NG-ASG"
asg_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Layer"         = "App"
  "Environment"   = "PROD",
  "Project"       = "CWM-Talent-Talker"
}
asg_security_group_egress_rules = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

asg_security_group_ingress_rules = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]
########################################################################
# Key Pair
########################################################################

# pritunl_kp_name  = "CWM-Pritunl-VPN-1b-keypair"
ecs_node_kp_name = "CWM-Talent-Talker-ECS-Node-keypair"
keypair_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Environment"   = "PROD",
  "Project"       = "CWM-Talent-Talker"
  "Layer"         = "Storage"
}

########################################################################
# ECR
########################################################################

repository_names = [
  "cwm-talent-talker-backend-prod",
  "cwm-talent-talker-vbot-v3.0-backend-prod",
  "cwm-talent-talker-ra-backend-prod",
]

ecr_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Environment"   = "PROD",
  "Project"       = "CWM-Talent-Talker"
  "Layer"         = "Storage"
}


# repository_names = [
#   "cwm-talent-talker-vbot-v3.0-backend-prod"
# ]

# ecr_tags = {
#   "Implementedby" = "Workmates",
#   "Managedby"     = "Workmates",
#   "Environment"   = "PROD",
#   "Project"       = "CWM-Talent-Talker"
#   "Layer"         = "Storage"
# }

###############################
# IAM 
###############################
create_iam_policy      = true
iam_policy_description = "ecs task exec addtional policy"
iam_policy_name        = "cwm-PROD-ecs-s3-env-access-policy"
iam_policy = {
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Sid" : "ecss3envaccess",
      "Effect" : "Allow",
      "Action" : [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource" : [
        "arn:aws:s3:::cwm-talent-talker-env-bucket",
        "arn:aws:s3:::cwm-talent-talker-env-bucket/*"
      ]
    },
    {
      "Sid" : "s3websiteaccess",
      "Effect" : "Allow",
      "Action" : [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObjectTagging",
        "s3:DeleteObject",
        "s3:PutObjectAcl"
      ],
      "Resource" : [
        "arn:aws:s3:::cwm-talent-talker-PROD-website",
        "arn:aws:s3:::cwm-talent-talker-PROD-website/*"
      ]
    },
    # {
    #   "Sid" : "cdninvalidation",
    #   "Effect" : "Allow",
    #   "Action" : [
    #     "s3:GetObject",
    #     "cloudfront:GetDistribution",
    #     "cloudfront:ListInvalidations",
    #     "cloudfront:GetInvalidation",
    #     "cloudfront:CreateInvalidation"
    #   ],
    #   "Resource" : [
    #     "arn:aws:cloudfront::766497522778:distribution/*"
    #   ]
    # }
  ]

}

iam_policy_tags = {
  "Implementedby" = "Workmates",
  "Managedby"     = "Workmates",
  "Environment"   = "PROD",
  "Layer"         = "Security",
  "Project"       = "CWM-Talent-Talker"
}
########################################################################
# AWS Bedrock Configuration - Sample Data (Commented Out)
########################################################################
# # Bedrock Model Invocation Logging
# enable_bedrock_logging              = true
# bedrock_log_group_name              = "talent-talker-bedrock-logs"
# bedrock_logging_role_arn            = "arn:aws:iam::123456789012:role/bedrock-logging-role"
# bedrock_logging_bucket_name         = "talent-talker-bedrock-logs"
# bedrock_logging_key_prefix          = "bedrock/logs/"
# bedrock_include_model_response_body = true
# bedrock_text_data_delivery_enabled  = true
# bedrock_image_data_delivery_enabled = false

# # Bedrock Custom Model
# create_bedrock_custom_model   = true
# bedrock_custom_model_name     = "talent-talker-custom-model"
# bedrock_base_model_id         = "anthropic.claude-3-sonnet-20240229-v1:0"
# bedrock_custom_model_role_arn = "arn:aws:iam::123456789012:role/bedrock-custom-model-role"
# bedrock_hyperparameters = {
#   "max_steps"      = "1000"
#   "learning_rate"  = "0.0001"
#   "batch_size"     = "32"
# }
# bedrock_s3_output_path          = "s3://talent-talker-bedrock-data/output/"
# bedrock_s3_training_data_path   = "s3://talent-talker-bedrock-data/training/"
# bedrock_s3_validation_data_path = "s3://talent-talker-bedrock-data/validation/"

# # Bedrock Guardrail
# create_bedrock_guardrail      = true
# bedrock_guardrail_name        = "talent-talker-guardrail"
# bedrock_guardrail_description = "Guardrail for Talent Talker application"
# bedrock_blocklist_content_policies = [
#   {
#     name        = "block-profanity"
#     description = "Block profanity in responses"
#     pattern     = "(profanity|offensive language)"
#   }
# ]
# bedrock_topic_policy_name        = "restricted-topics"
# bedrock_topic_policy_description = "Topics that should be restricted"
# bedrock_blocked_topics           = ["politics", "religion"]
# bedrock_pii_entities             = ["NAME", "EMAIL", "PHONE_NUMBER", "ADDRESS"]
# bedrock_blocked_words            = ["inappropriate", "offensive"]

# # Bedrock Knowledge Base
# create_bedrock_knowledge_base      = true
# bedrock_knowledge_base_name        = "talent-talker-kb"
# bedrock_knowledge_base_description = "Knowledge base for Talent Talker application"
# bedrock_knowledge_base_role_arn    = "arn:aws:iam::123456789012:role/bedrock-kb-role"
# bedrock_opensearch_collection_arn  = "arn:aws:aoss:ap-south-1:123456789012:collection/talent-talker-collection"
# bedrock_vector_field               = "embedding"
# bedrock_metadata_field             = "metadata"
# bedrock_text_field                 = "text"
# bedrock_embedding_model_id         = "amazon.titan-embed-text-v1"

# # Bedrock Agent
# create_bedrock_agent           = true
# bedrock_agent_name             = "talent-talker-agent"
# bedrock_agent_role_arn         = "arn:aws:iam::123456789012:role/bedrock-agent-role"
# bedrock_agent_description      = "Agent for Talent Talker application"
# bedrock_agent_instruction      = "You are an assistant that helps with talent acquisition and management."
# bedrock_agent_foundation_model = "anthropic.claude-3-sonnet-20240229-v1:0"
# bedrock_action_groups = [
#   {
#     name        = "talent-search"
#     description = "Search for talent in the database"
#     lambda_arn  = "arn:aws:lambda:ap-south-1:123456789012:function:talent-search"
#   },
#   {
#     name        = "schedule-interview"
#     description = "Schedule an interview with a candidate"
#     lambda_arn  = "arn:aws:lambda:ap-south-1:123456789012:function:schedule-interview"
#   }
# ]
# bedrock_agent_knowledge_bases = [
#   {
#     id          = "kb-12345"
#     description = "Talent database knowledge base"
#   }
# ]

########################################################################
# AWS Rekognition Configuration - Sample Data (Commented Out)
########################################################################
# # Rekognition Collection
# create_rekognition_collection = true
# rekognition_collection_id     = "talent-talker-faces"

# # Rekognition Project
# create_rekognition_project = true
# rekognition_project_name   = "talent-talker-project"

# # Rekognition Stream Processor
# create_rekognition_stream_processor   = true
# rekognition_stream_processor_name     = "talent-talker-stream-processor"
# rekognition_stream_processor_role_arn = "arn:aws:iam::123456789012:role/rekognition-stream-processor-role"
# rekognition_kinesis_video_stream_arn  = "arn:aws:kinesisvideo:ap-south-1:123456789012:stream/talent-talker-video-stream"
# rekognition_face_match_threshold      = 85
# rekognition_enable_connected_home     = false
# rekognition_notification_topic_arn    = "arn:aws:sns:ap-south-1:123456789012:talent-talker-notifications"
# rekognition_data_sharing_opt_in       = false

# # Rekognition Custom Labels Model
# create_rekognition_custom_labels_model = true
# rekognition_model_version_name         = "v1.0"
# rekognition_output_s3_bucket           = "talent-talker-rekognition-output"
# rekognition_output_s3_key_prefix       = "custom-labels/"
# rekognition_training_data_bucket       = "talent-talker-rekognition-data"
# rekognition_training_data_manifest_key = "manifests/training.json"
# rekognition_auto_create_testing_data   = false
# rekognition_testing_data_bucket        = "talent-talker-rekognition-data"
# rekognition_testing_data_manifest_key  = "manifests/testing.json"

# # Rekognition Project Policy
# create_rekognition_project_policy        = true
# rekognition_project_policy_principal_arns = [
#   "arn:aws:iam::123456789012:role/talent-talker-app-role"
# ]
# rekognition_project_policy_actions = [
#   "rekognition:DetectCustomLabels",
#   "rekognition:StartProjectVersion",
#   "rekognition:StopProjectVersion"
# ]

########################################################################
# AWS Polly Configuration - Sample Data (Commented Out)
########################################################################
# # Polly Lexicon
# create_polly_lexicon  = true
# polly_lexicon_name    = "talent-talker-lexicon"
# polly_lexicon_content = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><lexicon version=\"1.0\" xmlns=\"http://www.w3.org/2005/01/pronunciation-lexicon\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.w3.org/2005/01/pronunciation-lexicon http://www.w3.org/TR/2007/CR-pronunciation-lexicon-20071212/pls.xsd\" alphabet=\"ipa\" xml:lang=\"en-US\"><lexeme><grapheme>AWS</grapheme><alias>Amazon Web Services</alias></lexeme></lexicon>"

# # Polly S3 Output Bucket
# create_polly_output_bucket = true
# polly_output_bucket_name   = "talent-talker-polly-output"
# polly_force_destroy_bucket = true
# polly_enable_lifecycle_rules = true
# polly_expiration_days      = 30

# # Polly IAM Role
# create_polly_iam_role = true

# # Polly CloudWatch Logs
# create_polly_log_group    = true
# polly_log_retention_days  = 14
