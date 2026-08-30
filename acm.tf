module "acm_main" {
  source = "./modules/acm"

  create_certificate = true

  domain_name               = var.main_domain_name ### Ex- example.com
  zone_id                   = module.zones.route53_zone_zone_id["${var.main_domain_name}"]
  subject_alternative_names = ["*.${var.main_domain_name}"] ### *.example.com
  create_route53_records    = var.create_route53_records    ### if true Terraform will create CNAME  records in Route53 for certificate validation. If false, you need to validate the certificate manually from AWS console or CLI. 
  validation_method         = var.validation_method

  validate_certificate = var.validate_certificate ### Certificate validation will be done automatically by Terraform if you set create_route53_records to true. If you set create_route53_records to false, you need to validate the certificate manually from AWS console or CLI.


  tags = merge(var.acm_main_tags, {
    Name        = var.main_domain_name,
    Environment = var.environment,
    Project     = var.project_name
  })
}


## Below is the format to create ACM certificate in another aws region.
module "acm_virginia" {
  source = "./modules/acm"

  create_certificate = true

  domain_name               = var.main_domain_name
  zone_id                   = module.zones.route53_zone_zone_id["${var.main_domain_name}"]
  subject_alternative_names = ["*.${var.main_domain_name}"]
  create_route53_records    = var.create_route53_records
  validation_method         = var.validation_method
  validate_certificate      = var.validate_certificate

  tags = merge(var.acm_main_tags, {
    Name        = var.main_domain_name,
    Environment = var.environment,
    Project     = var.project_name
  })

  providers = {
    aws = aws.virginia ### CloudFront requires ACM certificate to be in us-east-1
  }
}