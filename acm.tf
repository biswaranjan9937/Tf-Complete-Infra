module "acm_main" {
  source = "./modules/acm"

  create_certificate = true

  domain_name               = var.main_domain_name          ### Ex- example.com
  subject_alternative_names = ["*.${var.main_domain_name}"] ### *.example.com
  create_route53_records    = var.create_route53_records
  validation_method         = var.validation_method

  validate_certificate = false ### Certificate validation will be done manually by creating a CNAME record in Route53.


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