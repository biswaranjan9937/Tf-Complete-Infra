module "acm_main" {
  source = "./modules/acm"

  create_certificate = true

  domain_name               = var.main_domain_name          ### Ex- example.com
  zone_id = module.zones.route53_zone_zone_id["${var.main_domain_name}"]
  # zone_id = module.zones.route53_zone_zone_id["seawhale.in"]
  subject_alternative_names = ["*.${var.main_domain_name}"] ### *.example.com
  create_route53_records    = var.create_route53_records    ### if true Terraform will create CNAME  records in Route53 for certificate validation. If false, you need to validate the certificate manually from AWS console or CLI. 
  validation_method         = var.validation_method

  validate_certificate = true ### Certificate validation will be done automatically by Terraform if you set create_route53_records to true. If you set create_route53_records to false, you need to validate the certificate manually from AWS console or CLI.


  tags = local.acm_main_tags
}


## Below is the format to create ACM certificate in another aws region.
# module "acm_nv" {    
#   source = "./modules/acm"

#   create_certificate = true

#   domain_name               = local.main_domain_name
#   subject_alternative_names = ["*.${local.main_domain_name}"]
#   create_route53_records    = local.create_route53_records
#   validation_method         = local.validation_method

#   validate_certificate = false

#   tags = local.acm_main_tags

#   providers = {
#     aws = aws.virginia
#   }
# }