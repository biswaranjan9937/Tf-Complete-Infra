########################################################################
# AWS Bedrock Module
########################################################################

resource "aws_bedrock_model_invocation_logging_configuration" "this" {
  count = var.enable_model_invocation_logging ? 1 : 0

  logging_config {
    cloudwatch_config {
      log_group_name = var.log_group_name
      role_arn       = var.logging_role_arn
    }

    s3_config {
      bucket_name = var.logging_bucket_name
      key_prefix  = var.logging_key_prefix
      role_arn    = var.logging_role_arn
    }

    include_model_response_body = var.include_model_response_body
    text_data_delivery_enabled  = var.text_data_delivery_enabled
    image_data_delivery_enabled = var.image_data_delivery_enabled
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-bedrock-logging"
    }
  )
}

resource "aws_bedrock_custom_model" "this" {
  count = var.create_custom_model ? 1 : 0

  custom_model_name = var.custom_model_name
  base_model_id     = var.base_model_id
  role_arn          = var.custom_model_role_arn

  hyperparameters = var.hyperparameters
  output_data_config {
    s3_output_path = var.s3_output_path
  }

  training_data_config {
    s3_training_data_path = var.s3_training_data_path
    s3_validation_data_path = var.s3_validation_data_path
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.custom_model_name}"
    }
  )
}

resource "aws_bedrock_guardrail" "this" {
  count = var.create_guardrail ? 1 : 0

  name        = var.guardrail_name
  description = var.guardrail_description

  blocklist_config {
    dynamic "content_policy" {
      for_each = var.blocklist_content_policies
      content {
        name        = content_policy.value.name
        description = content_policy.value.description
        content_filter {
          regex_filter {
            pattern = content_policy.value.pattern
          }
        }
      }
    }
  }

  topic_policy {
    name        = var.topic_policy_name
    description = var.topic_policy_description
    topics      = var.blocked_topics
  }

  sensitive_information_policy {
    pii_entities = var.pii_entities
  }

  word_policy {
    words = var.blocked_words
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.guardrail_name}"
    }
  )
}

resource "aws_bedrock_knowledge_base" "this" {
  count = var.create_knowledge_base ? 1 : 0

  name        = var.knowledge_base_name
  description = var.knowledge_base_description
  role_arn    = var.knowledge_base_role_arn

  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
      collection_arn = var.opensearch_collection_arn
      vector_field   = var.vector_field
      field_mapping {
        metadata_field = var.metadata_field
        text_field     = var.text_field
      }
    }
  }

  embedding_configuration {
    bedrock_embedding_configuration {
      model_id = var.embedding_model_id
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.knowledge_base_name}"
    }
  )
}

resource "aws_bedrock_agent" "this" {
  count = var.create_agent ? 1 : 0

  agent_name    = var.agent_name
  agent_resource_role_arn = var.agent_role_arn
  description   = var.agent_description
  instruction   = var.agent_instruction
  foundation_model = var.agent_foundation_model

  dynamic "action_group" {
    for_each = var.action_groups
    content {
      action_group_name = action_group.value.name
      description       = action_group.value.description
      action_group_executor {
        lambda {
          lambda_arn = action_group.value.lambda_arn
        }
      }
    }
  }

  dynamic "knowledge_base" {
    for_each = var.agent_knowledge_bases
    content {
      knowledge_base_id = knowledge_base.value.id
      description       = knowledge_base.value.description
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.agent_name}"
    }
  )
}
