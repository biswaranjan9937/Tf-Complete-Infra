########################################################################
# Rekognition Collection Outputs
########################################################################
output "collection_id" {
  description = "ID of the Rekognition collection"
  value       = try(aws_rekognition_collection.this[0].collection_id, null)
}

output "collection_arn" {
  description = "ARN of the Rekognition collection"
  value       = try(aws_rekognition_collection.this[0].arn, null)
}

########################################################################
# Rekognition Project Outputs
########################################################################
output "project_id" {
  description = "ID of the Rekognition project"
  value       = try(aws_rekognition_project.this[0].project_name, null)
}

output "project_arn" {
  description = "ARN of the Rekognition project"
  value       = try(aws_rekognition_project.this[0].arn, null)
}

########################################################################
# Rekognition Stream Processor Outputs
########################################################################
output "stream_processor_id" {
  description = "ID of the Rekognition stream processor"
  value       = try(aws_rekognition_stream_processor.this[0].name, null)
}

output "stream_processor_arn" {
  description = "ARN of the Rekognition stream processor"
  value       = try(aws_rekognition_stream_processor.this[0].arn, null)
}

########################################################################
# Rekognition Custom Labels Model Outputs
########################################################################
output "custom_labels_model_arn" {
  description = "ARN of the Rekognition custom labels model"
  value       = try(aws_rekognition_custom_labels_model.this[0].project_version_arn, null)
}

output "custom_labels_model_version" {
  description = "Version of the Rekognition custom labels model"
  value       = try(aws_rekognition_custom_labels_model.this[0].version_name, null)
}
