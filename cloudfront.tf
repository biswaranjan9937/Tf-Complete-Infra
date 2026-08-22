########################################################################
# CloudFront
########################################################################

module "cloudfront" {
  source = "./modules/cloudfront"

  create_distribution = true
  comment             = var.cf_comment
  enabled             = var.cf_enabled
  is_ipv6_enabled     = var.cf_is_ipv6_enabled
  price_class         = var.cf_price_class
  http_version        = var.cf_http_version
  default_root_object = var.cf_default_root_object
  aliases             = var.cf_aliases
  web_acl_id          = var.cf_web_acl_id
  retain_on_delete    = var.cf_retain_on_delete
  wait_for_deployment = var.cf_wait_for_deployment

  ########################################################################
  # Origin Access Control (OAC) — used for S3 origins with sigv4 signing
  ########################################################################
  create_origin_access_control = var.cf_create_origin_access_control
  origin_access_control        = var.cf_origin_access_control

  ########################################################################
  # Origins
  ########################################################################
  origin = var.cf_origin

  ########################################################################
  # Default Cache Behavior
  ########################################################################
  default_cache_behavior = var.cf_default_cache_behavior

  ########################################################################
  # Ordered Cache Behaviors (optional path-based routing)
  ########################################################################
  ordered_cache_behavior = var.cf_ordered_cache_behavior

  ########################################################################
  # Custom Error Responses
  ########################################################################
  custom_error_response = var.cf_custom_error_response

  ########################################################################
  # Viewer Certificate — uses ACM cert created by acm.tf
  ########################################################################
  viewer_certificate = {
    acm_certificate_arn      = module.acm_virginia.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  ########################################################################
  # Geo Restriction
  ########################################################################
  geo_restriction = var.cf_geo_restriction

  ########################################################################
  # Logging
  ########################################################################
  logging_config = var.cf_logging_config

  ########################################################################
  # Monitoring Subscription
  ########################################################################
  create_monitoring_subscription       = var.cf_create_monitoring_subscription
  realtime_metrics_subscription_status = var.cf_realtime_metrics_subscription_status

  tags = merge(var.cf_tags, {
    Name        = "${var.project_name}-${var.environment}-CloudFront",
    Environment = var.environment,
    Project     = var.project_name
  })
}
