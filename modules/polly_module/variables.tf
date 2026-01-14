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
# Polly Lexicon Variables
########################################################################
variable "create_lexicon" {
  description = "Whether to create a Polly lexicon"
  type        = bool
  default     = false
}

variable "lexicon_name" {
  description = "Name of the Polly lexicon"
  type        = string
  default     = null
}

variable "lexicon_content" {
  description = "Content of the Polly lexicon in PLS format"
  type        = string
  default     = null
}

########################################################################
# S3 Output Bucket Variables
########################################################################
variable "create_output_bucket" {
  description = "Whether to create an S3 bucket for Polly output"
  type        = bool
  default     = false
}

variable "output_bucket_name" {
  description = "Name of the S3 bucket for Polly output"
  type        = string
  default     = null
}

variable "force_destroy_bucket" {
  description = "Whether to force destroy the S3 bucket even if it contains objects"
  type        = bool
  default     = false
}

variable "enable_lifecycle_rules" {
  description = "Whether to enable lifecycle rules for the S3 bucket"
  type        = bool
  default     = false
}

variable "expiration_days" {
  description = "Number of days after which objects should expire"
  type        = number
  default     = 30
}

########################################################################
# IAM Role Variables
########################################################################
variable "create_iam_role" {
  description = "Whether to create an IAM role for Polly"
  type        = bool
  default     = false
}

########################################################################
# CloudWatch Logs Variables
########################################################################
variable "create_log_group" {
  description = "Whether to create a CloudWatch log group for Polly"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 14
}
