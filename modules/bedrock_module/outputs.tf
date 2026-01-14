########################################################################
# Bedrock Model Invocation Logging Outputs
########################################################################
output "bedrock_logging_configuration_id" {
  description = "ID of the Bedrock model invocation logging configuration"
  value       = try(aws_bedrock_model_invocation_logging_configuration.this[0].id, null)
}

########################################################################
# Bedrock Custom Model Outputs
########################################################################
output "custom_model_id" {
  description = "ID of the custom Bedrock model"
  value       = try(aws_bedrock_custom_model.this[0].id, null)
}

output "custom_model_arn" {
  description = "ARN of the custom Bedrock model"
  value       = try(aws_bedrock_custom_model.this[0].arn, null)
}

########################################################################
# Bedrock Guardrail Outputs
########################################################################
output "guardrail_id" {
  description = "ID of the Bedrock guardrail"
  value       = try(aws_bedrock_guardrail.this[0].id, null)
}

output "guardrail_arn" {
  description = "ARN of the Bedrock guardrail"
  value       = try(aws_bedrock_guardrail.this[0].arn, null)
}

########################################################################
# Bedrock Knowledge Base Outputs
########################################################################
output "knowledge_base_id" {
  description = "ID of the Bedrock knowledge base"
  value       = try(aws_bedrock_knowledge_base.this[0].id, null)
}

output "knowledge_base_arn" {
  description = "ARN of the Bedrock knowledge base"
  value       = try(aws_bedrock_knowledge_base.this[0].arn, null)
}

########################################################################
# Bedrock Agent Outputs
########################################################################
output "agent_id" {
  description = "ID of the Bedrock agent"
  value       = try(aws_bedrock_agent.this[0].id, null)
}

output "agent_arn" {
  description = "ARN of the Bedrock agent"
  value       = try(aws_bedrock_agent.this[0].arn, null)
}
