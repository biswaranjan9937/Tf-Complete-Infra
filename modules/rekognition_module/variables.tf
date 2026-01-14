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
# Rekognition Collection Variables
########################################################################
variable "create_collection" {
  description = "Whether to create a Rekognition collection"
  type        = bool
  default     = false
}

variable "collection_id" {
  description = "ID for the Rekognition collection"
  type        = string
  default     = null
}

########################################################################
# Rekognition Project Variables
########################################################################
variable "create_project" {
  description = "Whether to create a Rekognition project"
  type        = bool
  default     = false
}

variable "project_name" {
  description = "Name for the Rekognition project"
  type        = string
  default     = null
}

variable "project_arn" {
  description = "ARN of an existing Rekognition project"
  type        = string
  default     = null
}

########################################################################
# Rekognition Stream Processor Variables
########################################################################
variable "create_stream_processor" {
  description = "Whether to create a Rekognition stream processor"
  type        = bool
  default     = false
}

variable "stream_processor_name" {
  description = "Name for the Rekognition stream processor"
  type        = string
  default     = null
}

variable "stream_processor_role_arn" {
  description = "IAM role ARN for the stream processor"
  type        = string
  default     = null
}

variable "kinesis_video_stream_arn" {
  description = "ARN of the Kinesis video stream"
  type        = string
  default     = null
}

variable "face_match_threshold" {
  description = "Threshold for face matching"
  type        = number
  default     = 80
}

variable "enable_connected_home" {
  description = "Whether to enable connected home features"
  type        = bool
  default     = false
}

variable "connected_home_labels" {
  description = "Labels for connected home configuration"
  type        = list(string)
  default     = []
}

variable "notification_topic_arn" {
  description = "ARN of the SNS topic for notifications"
  type        = string
  default     = null
}

variable "data_sharing_opt_in" {
  description = "Whether to opt in to data sharing"
  type        = bool
  default     = false
}

########################################################################
# Rekognition Custom Labels Model Variables
########################################################################
variable "create_custom_labels_model" {
  description = "Whether to create a Rekognition custom labels model"
  type        = bool
  default     = false
}

variable "model_version_name" {
  description = "Version name for the custom labels model"
  type        = string
  default     = null
}

variable "output_s3_bucket" {
  description = "S3 bucket for model output"
  type        = string
  default     = null
}

variable "output_s3_key_prefix" {
  description = "S3 key prefix for model output"
  type        = string
  default     = "rekognition-output/"
}

variable "training_data_bucket" {
  description = "S3 bucket containing training data"
  type        = string
  default     = null
}

variable "training_data_manifest_key" {
  description = "S3 key for training data manifest"
  type        = string
  default     = null
}

variable "auto_create_testing_data" {
  description = "Whether to auto-create testing data"
  type        = bool
  default     = true
}

variable "testing_data_bucket" {
  description = "S3 bucket containing testing data"
  type        = string
  default     = null
}

variable "testing_data_manifest_key" {
  description = "S3 key for testing data manifest"
  type        = string
  default     = null
}

########################################################################
# Rekognition Project Policy Variables
########################################################################
variable "create_project_policy" {
  description = "Whether to create a Rekognition project policy"
  type        = bool
  default     = false
}

variable "project_policy_principal_arns" {
  description = "List of principal ARNs for the project policy"
  type        = list(string)
  default     = []
}

variable "project_policy_actions" {
  description = "List of actions for the project policy"
  type        = list(string)
  default     = [
    "rekognition:CreateProjectVersion",
    "rekognition:StartProjectVersion",
    "rekognition:StopProjectVersion",
    "rekognition:DetectCustomLabels"
  ]
}
