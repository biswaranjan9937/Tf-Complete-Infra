########################################################################
# Common Variables
########################################################################
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

########################################################################
# Bedrock Model Invocation Logging Variables
########################################################################
variable "enable_model_invocation_logging" {
  description = "Whether to enable model invocation logging"
  type        = bool
  default     = false
}

variable "log_group_name" {
  description = "CloudWatch log group name for Bedrock logging"
  type        = string
  default     = null
}

variable "logging_role_arn" {
  description = "IAM role ARN for Bedrock logging"
  type        = string
  default     = null
}

variable "logging_bucket_name" {
  description = "S3 bucket name for Bedrock logging"
  type        = string
  default     = null
}

variable "logging_key_prefix" {
  description = "S3 key prefix for Bedrock logging"
  type        = string
  default     = "bedrock-logs/"
}

variable "include_model_response_body" {
  description = "Whether to include model response body in logs"
  type        = bool
  default     = true
}

variable "text_data_delivery_enabled" {
  description = "Whether to enable text data delivery"
  type        = bool
  default     = true
}

variable "image_data_delivery_enabled" {
  description = "Whether to enable image data delivery"
  type        = bool
  default     = false
}

########################################################################
# Bedrock Custom Model Variables
########################################################################
variable "create_custom_model" {
  description = "Whether to create a custom Bedrock model"
  type        = bool
  default     = false
}

variable "custom_model_name" {
  description = "Name of the custom Bedrock model"
  type        = string
  default     = null
}

variable "base_model_id" {
  description = "Base model ID for the custom model"
  type        = string
  default     = null
}

variable "custom_model_role_arn" {
  description = "IAM role ARN for the custom model"
  type        = string
  default     = null
}

variable "hyperparameters" {
  description = "Hyperparameters for the custom model"
  type        = map(string)
  default     = {}
}

variable "s3_output_path" {
  description = "S3 output path for the custom model"
  type        = string
  default     = null
}

variable "s3_training_data_path" {
  description = "S3 training data path for the custom model"
  type        = string
  default     = null
}

variable "s3_validation_data_path" {
  description = "S3 validation data path for the custom model"
  type        = string
  default     = null
}

########################################################################
# Bedrock Guardrail Variables
########################################################################
variable "create_guardrail" {
  description = "Whether to create a Bedrock guardrail"
  type        = bool
  default     = false
}

variable "guardrail_name" {
  description = "Name of the Bedrock guardrail"
  type        = string
  default     = null
}

variable "guardrail_description" {
  description = "Description of the Bedrock guardrail"
  type        = string
  default     = null
}

variable "blocklist_content_policies" {
  description = "List of content policies for the blocklist"
  type = list(object({
    name        = string
    description = string
    pattern     = string
  }))
  default = []
}

variable "topic_policy_name" {
  description = "Name of the topic policy"
  type        = string
  default     = null
}

variable "topic_policy_description" {
  description = "Description of the topic policy"
  type        = string
  default     = null
}

variable "blocked_topics" {
  description = "List of blocked topics"
  type        = list(string)
  default     = []
}

variable "pii_entities" {
  description = "List of PII entities to block"
  type        = list(string)
  default     = []
}

variable "blocked_words" {
  description = "List of blocked words"
  type        = list(string)
  default     = []
}

########################################################################
# Bedrock Knowledge Base Variables
########################################################################
variable "create_knowledge_base" {
  description = "Whether to create a Bedrock knowledge base"
  type        = bool
  default     = false
}

variable "knowledge_base_name" {
  description = "Name of the Bedrock knowledge base"
  type        = string
  default     = null
}

variable "knowledge_base_description" {
  description = "Description of the Bedrock knowledge base"
  type        = string
  default     = null
}

variable "knowledge_base_role_arn" {
  description = "IAM role ARN for the knowledge base"
  type        = string
  default     = null
}

variable "opensearch_collection_arn" {
  description = "ARN of the OpenSearch collection"
  type        = string
  default     = null
}

variable "vector_field" {
  description = "Vector field name in OpenSearch"
  type        = string
  default     = "embedding"
}

variable "metadata_field" {
  description = "Metadata field name in OpenSearch"
  type        = string
  default     = "metadata"
}

variable "text_field" {
  description = "Text field name in OpenSearch"
  type        = string
  default     = "text"
}

variable "embedding_model_id" {
  description = "Model ID for embeddings"
  type        = string
  default     = "amazon.titan-embed-text-v1"
}

########################################################################
# Bedrock Agent Variables
########################################################################
variable "create_agent" {
  description = "Whether to create a Bedrock agent"
  type        = bool
  default     = false
}

variable "agent_name" {
  description = "Name of the Bedrock agent"
  type        = string
  default     = null
}

variable "agent_role_arn" {
  description = "IAM role ARN for the agent"
  type        = string
  default     = null
}

variable "agent_description" {
  description = "Description of the Bedrock agent"
  type        = string
  default     = null
}

variable "agent_instruction" {
  description = "Instruction for the Bedrock agent"
  type        = string
  default     = null
}

variable "agent_foundation_model" {
  description = "Foundation model for the Bedrock agent"
  type        = string
  default     = "anthropic.claude-3-sonnet-20240229-v1:0"
}

variable "action_groups" {
  description = "List of action groups for the agent"
  type = list(object({
    name        = string
    description = string
    lambda_arn  = string
  }))
  default = []
}

variable "agent_knowledge_bases" {
  description = "List of knowledge bases for the agent"
  type = list(object({
    id          = string
    description = string
  }))
  default = []
}
