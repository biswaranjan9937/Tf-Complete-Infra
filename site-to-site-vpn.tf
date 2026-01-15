# module "vpn_connection" {
#     source = "./modules/site-to-site-VPN"
#     # Cloud Posse recommends pinning every module to a specific version
#     # version = "x.x.x"
#     namespace                                 = "Innervex-Technologies"
#     stage                                     = "PROD"
#     name                                      = "Innervex-Technologies-S2S-VPN"
#     vpc_id                                    = module.vpc.vpc_id
#     # vpn_gateway_amazon_side_asn               = 64512
#     customer_gateway_bgp_asn                  = 65000
#     customer_gateway_ip_address               = "15.206.48.168"     #### need to change to your on-prem public IP
#    route_table_ids                           = concat(
#       module.vpc.private_route_table_ids,
#       module.vpc.public_route_table_ids
#     )
#     vpn_connection_static_routes_only         = "true"
#     vpn_connection_static_routes_destinations = ["10.80.1.0/24"]
#     depends_on = [ module.vpc ]
#   }