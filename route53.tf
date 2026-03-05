module "zones" {
  source = "./modules/route53_module/zones"
  create = true
  zones = {
    "${var.main_domain_name}" = {
      comment = "${var.main_domain_name} (poc)"
    }
  }
  # zones = {
  #   "seawhale.in" = {
  #     comment = "seawhale.in (poc)"
  #     tags = {
  #       Name          = "seawhale.in"
  #       Implementedby = "Workmates"
  #       Managedby     = "Workmates"
  #       Ennvironment  = "POC"
  #       Project       = "INCEDE"
  #       Layer         = "DNS"
  #     }
  #   }
  # }

  tags = local.zone_tags
}
