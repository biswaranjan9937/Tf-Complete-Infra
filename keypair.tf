/*
Key pair retrrivel issue in generalized pipeline
*/
locals {
  #pritunl_kp_name  = var.pritunl_kp_name
  ecs_node_kp_name = var.ecs_node_kp_name
  tags             = var.keypair_tags
}
# module "pritunl_key_pair" {
#   source = "./modules/key-pair"

#   key_name           = local.pritunl_kp_name
#   create_private_key = true

#   tags = local.tags
# }

module "ecs_node_key_pair" {
  source = "./modules/key-pair"

  key_name           = local.ecs_node_kp_name
  create_private_key = true
  tags               = local.tags



}