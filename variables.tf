variable "environment" {
  type = string
}
variable "region_backend" {
  type = string
}

########################################################################
# KeyPair
########################################################################
# variable "pritunl_kp_name" {
#   type = string
# }
variable "ecs_node_kp_name" {
  type = string
}
variable "keypair_tags" {
  type = map(string)
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

# variable "rds_snapshot_identifier" {
#   type = string
# }

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


#######################################################################
# variable "zone_tags" {
#   type = map(string)
# }
#######################################################################
########################################################################
# ECS
########################################################################
variable "ecs_cluster_name" {
  type = string
}

variable "ecs_cluster_settings" {
  type = any
}
variable "ecs_cluster_tags" {
  type = map(string)
}
# variable "ecs_service_name" {
#   type = string
# }
# variable "ecs_container_name" {
#   type = string
# }
# variable "ecs_container_port" {
#   type = string
# }
# variable "ecs_service_tags" {
#   type = map(string)
# }

########################################################################
# ASG
########################################################################
variable "asg_name" {
  type = string
}
variable "asg_tags" {
  type = map(string)
}
variable "asg_security_group_ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "asg_security_group_egress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

######################################
# Elastic Contianer Registry
######################################
variable "ecr_tags" {
  type = map(string)
}

variable "repository_names" {
  type = list(string)
}

#####################################
# IAM
#####################################

variable "create_iam_policy" {
  type = bool
}

variable "iam_policy_description" {
  type = string
}

variable "iam_policy_name" {
  type = string
}

variable "iam_policy" {
  type = any
}

variable "iam_policy_tags" {
  type = map(string)
}
########################################################################
# Bedrock Variables
########################################################################
variable "enable_bedrock_logging" {
  description = "Whether to enable Bedrock model invocation logging"
  type        = bool
  default     = false
}

variable "bedrock_log_group_name" {
  description = "CloudWatch log group name for Bedrock logging"
  type        = string
  default     = null
}

variable "bedrock_logging_role_arn" {
  description = "IAM role ARN for Bedrock logging"
  type        = string
  default     = null
}

variable "bedrock_logging_bucket_name" {
  description = "S3 bucket name for Bedrock logging"
  type        = string
  default     = null
}

variable "bedrock_logging_key_prefix" {
  description = "S3 key prefix for Bedrock logging"
  type        = string
  default     = "bedrock-logs/"
}

variable "bedrock_include_model_response_body" {
  description = "Whether to include model response body in logs"
  type        = bool
  default     = true
}

variable "bedrock_text_data_delivery_enabled" {
  description = "Whether to enable text data delivery"
  type        = bool
  default     = true
}

variable "bedrock_image_data_delivery_enabled" {
  description = "Whether to enable image data delivery"
  type        = bool
  default     = false
}

variable "create_bedrock_custom_model" {
  description = "Whether to create a custom Bedrock model"
  type        = bool
  default     = false
}

variable "bedrock_custom_model_name" {
  description = "Name of the custom Bedrock model"
  type        = string
  default     = null
}

variable "bedrock_base_model_id" {
  description = "Base model ID for the custom model"
  type        = string
  default     = null
}

variable "bedrock_custom_model_role_arn" {
  description = "IAM role ARN for the custom model"
  type        = string
  default     = null
}

variable "bedrock_hyperparameters" {
  description = "Hyperparameters for the custom model"
  type        = map(string)
  default     = {}
}

variable "bedrock_s3_output_path" {
  description = "S3 output path for the custom model"
  type        = string
  default     = null
}

variable "bedrock_s3_training_data_path" {
  description = "S3 training data path for the custom model"
  type        = string
  default     = null
}

variable "bedrock_s3_validation_data_path" {
  description = "S3 validation data path for the custom model"
  type        = string
  default     = null
}

variable "create_bedrock_guardrail" {
  description = "Whether to create a Bedrock guardrail"
  type        = bool
  default     = false
}

variable "bedrock_guardrail_name" {
  description = "Name of the Bedrock guardrail"
  type        = string
  default     = null
}

variable "bedrock_guardrail_description" {
  description = "Description of the Bedrock guardrail"
  type        = string
  default     = null
}

variable "bedrock_blocklist_content_policies" {
  description = "List of content policies for the blocklist"
  type = list(object({
    name        = string
    description = string
    pattern     = string
  }))
  default = []
}

variable "bedrock_topic_policy_name" {
  description = "Name of the topic policy"
  type        = string
  default     = null
}

variable "bedrock_topic_policy_description" {
  description = "Description of the topic policy"
  type        = string
  default     = null
}

variable "bedrock_blocked_topics" {
  description = "List of blocked topics"
  type        = list(string)
  default     = []
}

variable "bedrock_pii_entities" {
  description = "List of PII entities to block"
  type        = list(string)
  default     = []
}

variable "bedrock_blocked_words" {
  description = "List of blocked words"
  type        = list(string)
  default     = []
}

variable "create_bedrock_knowledge_base" {
  description = "Whether to create a Bedrock knowledge base"
  type        = bool
  default     = false
}

variable "bedrock_knowledge_base_name" {
  description = "Name of the Bedrock knowledge base"
  type        = string
  default     = null
}

variable "bedrock_knowledge_base_description" {
  description = "Description of the Bedrock knowledge base"
  type        = string
  default     = null
}

variable "bedrock_knowledge_base_role_arn" {
  description = "IAM role ARN for the knowledge base"
  type        = string
  default     = null
}

variable "bedrock_opensearch_collection_arn" {
  description = "ARN of the OpenSearch collection"
  type        = string
  default     = null
}

variable "bedrock_vector_field" {
  description = "Vector field name in OpenSearch"
  type        = string
  default     = "embedding"
}

variable "bedrock_metadata_field" {
  description = "Metadata field name in OpenSearch"
  type        = string
  default     = "metadata"
}

variable "bedrock_text_field" {
  description = "Text field name in OpenSearch"
  type        = string
  default     = "text"
}

variable "bedrock_embedding_model_id" {
  description = "Model ID for embeddings"
  type        = string
  default     = "amazon.titan-embed-text-v1"
}

variable "create_bedrock_agent" {
  description = "Whether to create a Bedrock agent"
  type        = bool
  default     = false
}

variable "bedrock_agent_name" {
  description = "Name of the Bedrock agent"
  type        = string
  default     = null
}

variable "bedrock_agent_role_arn" {
  description = "IAM role ARN for the agent"
  type        = string
  default     = null
}

variable "bedrock_agent_description" {
  description = "Description of the Bedrock agent"
  type        = string
  default     = null
}

variable "bedrock_agent_instruction" {
  description = "Instruction for the Bedrock agent"
  type        = string
  default     = null
}

variable "bedrock_agent_foundation_model" {
  description = "Foundation model for the Bedrock agent"
  type        = string
  default     = "anthropic.claude-3-sonnet-20240229-v1:0"
}

variable "bedrock_action_groups" {
  description = "List of action groups for the agent"
  type = list(object({
    name        = string
    description = string
    lambda_arn  = string
  }))
  default = []
}

variable "bedrock_agent_knowledge_bases" {
  description = "List of knowledge bases for the agent"
  type = list(object({
    id          = string
    description = string
  }))
  default = []
}

########################################################################
# Rekognition Variables
########################################################################
variable "create_rekognition_collection" {
  description = "Whether to create a Rekognition collection"
  type        = bool
  default     = false
}

variable "rekognition_collection_id" {
  description = "ID for the Rekognition collection"
  type        = string
  default     = null
}

variable "create_rekognition_project" {
  description = "Whether to create a Rekognition project"
  type        = bool
  default     = false
}

variable "rekognition_project_name" {
  description = "Name for the Rekognition project"
  type        = string
  default     = null
}

variable "rekognition_project_arn" {
  description = "ARN of an existing Rekognition project"
  type        = string
  default     = null
}

variable "create_rekognition_stream_processor" {
  description = "Whether to create a Rekognition stream processor"
  type        = bool
  default     = false
}

variable "rekognition_stream_processor_name" {
  description = "Name for the Rekognition stream processor"
  type        = string
  default     = null
}

variable "rekognition_stream_processor_role_arn" {
  description = "IAM role ARN for the stream processor"
  type        = string
  default     = null
}

variable "rekognition_kinesis_video_stream_arn" {
  description = "ARN of the Kinesis video stream"
  type        = string
  default     = null
}

variable "rekognition_face_match_threshold" {
  description = "Threshold for face matching"
  type        = number
  default     = 80
}

variable "rekognition_enable_connected_home" {
  description = "Whether to enable connected home features"
  type        = bool
  default     = false
}

variable "rekognition_connected_home_labels" {
  description = "Labels for connected home configuration"
  type        = list(string)
  default     = []
}

variable "rekognition_notification_topic_arn" {
  description = "ARN of the SNS topic for notifications"
  type        = string
  default     = null
}

variable "rekognition_data_sharing_opt_in" {
  description = "Whether to opt in to data sharing"
  type        = bool
  default     = false
}

variable "create_rekognition_custom_labels_model" {
  description = "Whether to create a Rekognition custom labels model"
  type        = bool
  default     = false
}

variable "rekognition_model_version_name" {
  description = "Version name for the custom labels model"
  type        = string
  default     = null
}

variable "rekognition_output_s3_bucket" {
  description = "S3 bucket for model output"
  type        = string
  default     = null
}

variable "rekognition_output_s3_key_prefix" {
  description = "S3 key prefix for model output"
  type        = string
  default     = "rekognition-output/"
}

variable "rekognition_training_data_bucket" {
  description = "S3 bucket containing training data"
  type        = string
  default     = null
}

variable "rekognition_training_data_manifest_key" {
  description = "S3 key for training data manifest"
  type        = string
  default     = null
}

variable "rekognition_auto_create_testing_data" {
  description = "Whether to auto-create testing data"
  type        = bool
  default     = true
}

variable "rekognition_testing_data_bucket" {
  description = "S3 bucket containing testing data"
  type        = string
  default     = null
}

variable "rekognition_testing_data_manifest_key" {
  description = "S3 key for testing data manifest"
  type        = string
  default     = null
}

variable "create_rekognition_project_policy" {
  description = "Whether to create a Rekognition project policy"
  type        = bool
  default     = false
}

variable "rekognition_project_policy_principal_arns" {
  description = "List of principal ARNs for the project policy"
  type        = list(string)
  default     = []
}

variable "rekognition_project_policy_actions" {
  description = "List of actions for the project policy"
  type        = list(string)
  default     = [
    "rekognition:CreateProjectVersion",
    "rekognition:StartProjectVersion",
    "rekognition:StopProjectVersion",
    "rekognition:DetectCustomLabels"
  ]
}

########################################################################
# Polly Variables
########################################################################
variable "create_polly_lexicon" {
  description = "Whether to create a Polly lexicon"
  type        = bool
  default     = false
}

variable "polly_lexicon_name" {
  description = "Name of the Polly lexicon"
  type        = string
  default     = null
}

variable "polly_lexicon_content" {
  description = "Content of the Polly lexicon in PLS format"
  type        = string
  default     = null
}

variable "create_polly_output_bucket" {
  description = "Whether to create an S3 bucket for Polly output"
  type        = bool
  default     = false
}

variable "polly_output_bucket_name" {
  description = "Name of the S3 bucket for Polly output"
  type        = string
  default     = null
}

variable "polly_force_destroy_bucket" {
  description = "Whether to force destroy the S3 bucket even if it contains objects"
  type        = bool
  default     = false
}

variable "polly_enable_lifecycle_rules" {
  description = "Whether to enable lifecycle rules for the S3 bucket"
  type        = bool
  default     = false
}

variable "polly_expiration_days" {
  description = "Number of days after which objects should expire"
  type        = number
  default     = 30
}

variable "create_polly_iam_role" {
  description = "Whether to create an IAM role for Polly"
  type        = bool
  default     = false
}

variable "create_polly_log_group" {
  description = "Whether to create a CloudWatch log group for Polly"
  type        = bool
  default     = false
}

variable "polly_log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 14
}
