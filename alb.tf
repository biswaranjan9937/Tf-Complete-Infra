module "alb-global-securtiy-group" {
  source      = "./modules/sg"
  name        = var.alb_sg_name
  description = "alb-global Security group"
  vpc_id      = local.alb_vpc_id

  ingress_rules = local.alb_global_ingress_rules
  egress_rules  = local.alb_global_egress_rules
}

module "alb" {
  source = "./modules/loadbalancer_module"

  name = var.alb_name

  load_balancer_type = "application"

  vpc_id  = module.vpc.vpc_id
  subnets = [element(module.vpc.public_subnets, 0), element(module.vpc.public_subnets, 1)]

  enable_deletion_protection = true
  access_logs = {
    enabled = true
    bucket  = var.alb_access_logs_s3_bucket
    prefix  = var.alb_access_logs_s3_prefix
  }

  # Security Group
  security_groups = [module.alb-global-securtiy-group.security_group_id]

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "uat_ec2"
      }
    }
    # https = {
    #   port            = 443
    #   protocol        = "HTTPS"
    #   ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
    #   certificate_arn = module.acm_main.acm_certificate_arn
    #   #additional_certificate_arns = [module.wildcard_cert.acm_certificate_arn]
    #   # forward = {
    #   #   target_group_key = "app_ecs"
    #   # }
    #   fixed_response = {
    #     content_type = "text/plain",
    #     message_body = "Request Correct URL",
    #     status_code  = "404"
    #   }
    #   rules = {
    #     back_revmigrate_com = {
    #       priority = 1
    #       actions = [
    #         {
    #           type             = "forward"
    #           target_group_key = "app_ecs"
    #         }
    #       ]
    #       conditions = [{ host_header = { values = ["back.revmigrate.com"] } }]
    #     }
    #   }
    # }
  }

  target_groups = {
    uat_ec2 = {
      backend_protocol                  = "HTTP"
      backend_port                      = "80"
      name                              = var.uat_ec2_tg_name
      target_type                       = "instance"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

      create_attachment = true
      targets = {
        uat_instance = {
          target_id = module.uat.id
          port      = 80
        }
      }
    }
  }

  tags = local.alb_tags
}