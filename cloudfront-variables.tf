########################################################################
# CloudFront Variables
########################################################################

variable "cf_create_distribution" {
  description = "Controls if CloudFront distribution should be created"
  type        = bool
  default     = true
}

variable "cf_comment" {
  description = "Any comments you want to include about the distribution"
  type        = string
  default     = null
}

variable "cf_enabled" {
  description = "Whether the distribution is enabled to accept end user requests"
  type        = bool
  default     = true
}

variable "cf_is_ipv6_enabled" {
  description = "Whether IPv6 is enabled for the distribution"
  type        = bool
  default     = true
}

variable "cf_price_class" {
  description = "Price class for the distribution. One of PriceClass_All, PriceClass_200, PriceClass_100"
  type        = string
  default     = "PriceClass_All"
}

variable "cf_http_version" {
  description = "Maximum HTTP version to support. Allowed values: http1.1, http2, http2and3, http3"
  type        = string
  default     = "http2"
}

variable "cf_default_root_object" {
  description = "Object that CloudFront returns when an end user requests the root URL (e.g. index.html)"
  type        = string
  default     = "index.html"
}

variable "cf_aliases" {
  description = "Extra CNAMEs (alternate domain names) for this distribution"
  type        = list(string)
  default     = []
}

variable "cf_web_acl_id" {
  description = "ARN of the AWS WAF web ACL to associate with the distribution"
  type        = string
  default     = null
}

variable "cf_retain_on_delete" {
  description = "Disables the distribution instead of deleting it when destroying via Terraform"
  type        = bool
  default     = false
}

variable "cf_wait_for_deployment" {
  description = "If true, waits for distribution status to change from InProgress to Deployed"
  type        = bool
  default     = true
}

########################################################################
# Origin Access Control
########################################################################

variable "cf_create_origin_access_control" {
  description = "Controls if CloudFront origin access control should be created"
  type        = bool
  default     = true
}

variable "cf_origin_access_control" {
  description = "Map of CloudFront origin access control configurations"

  type = map(object({
    description      = string
    origin_type      = string
    signing_behavior = string
    signing_protocol = string
  }))

  default = {
    s3 = {
      description      = "OAC for S3"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }
}

########################################################################
# Origins
########################################################################

variable "cf_origin" {
  description = "One or more origins for this distribution"

  type = map(object({
    domain_name           = string
    origin_id             = optional(string)
    origin_access_control = optional(string)
  }))

  default = {
    s3 = {
      domain_name           = "test-s3-bucket-cdn.s3.ap-south-1.amazonaws.com"
      origin_id             = "test-s3-bucket-cdn"
      origin_access_control = "s3"
    }
  }
}

########################################################################
# Cache Behaviors
########################################################################

variable "cf_default_cache_behavior" {
  description = "The default cache behavior for this distribution"

  type = any

  default = {
    target_origin_id       = "test-s3-bucket-cdn"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS"
    ]

    cached_methods = [
      "GET",
      "HEAD"
    ]

    compress = true

    use_forwarded_values = false

    cache_policy_name = "Managed-CachingOptimized"
  }
}

variable "cf_ordered_cache_behavior" {
  description = "Ordered list of cache behaviors. Top to bottom in order of precedence"
  type        = any

  default = [
    {
      path_pattern           = "/static/*"
      target_origin_id       = "test-s3-bucket-cdn"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = [
        "GET",
        "HEAD",
        "OPTIONS"
      ]

      cached_methods = [
        "GET",
        "HEAD"
      ]

      compress = true

      use_forwarded_values = false

      cache_policy_name = "Managed-CachingOptimized"
    }
  ]
}

########################################################################
# Custom Error Responses
########################################################################

variable "cf_custom_error_response" {
  description = "One or more custom error response elements"
  type        = any
  default     = {}
}

########################################################################
# Geo Restriction
########################################################################

variable "cf_geo_restriction" {
  description = "Geo restriction configuration for the distribution"
  type        = any
  default     = {}
}

########################################################################
# Logging
########################################################################

variable "cf_logging_config" {
  description = "Logging configuration that controls how logs are written to your distribution"
  type        = any
  default     = {}
}

########################################################################
# Monitoring
########################################################################

variable "cf_create_monitoring_subscription" {
  description = "If enabled, creates the resource for monitoring subscription"
  type        = bool
  default     = false
}

variable "cf_realtime_metrics_subscription_status" {
  description = "Whether additional CloudWatch metrics are enabled. Valid values: Enabled, Disabled"
  type        = string
  default     = "Enabled"
}

########################################################################
# Tags
########################################################################

variable "cf_tags" {
  description = "A map of tags to assign to the CloudFront distribution"
  type        = map(string)
  default     = {}
}
