module "zones" {
  source = "./modules/r53_module/zones"
  create = true

  zones = {
    "seawhale.in" = {
      comment = "seawhale.in (poc)"
      tags = {
        Name          = "seawhale.in"
        Implementedby = "Workmates"
        Managedby     = "Workmates"
        Ennvironment  = "POC"
        Project       = "INCEDE"
        Layer         = "DNS"
      }
    }
  }

  tags = local.zone_tags
}
