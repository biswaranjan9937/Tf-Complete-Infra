module "prod-securtiy-group" {
  source      = "./modules/sg"
  name        = "${title(var.prod_name)}-SGs"
  description = "${title(var.prod_name)} Security group"
  vpc_id      = module.vpc.vpc_id
  ingress_rules = var.prod_ingress_rules
  egress_rules  = var.prod_egress_rules
}

module "prod" {
  count      = 1
  source     = "./modules/ec2"
  depends_on = [module.prod-securtiy-group]
  create     = true
  name       = var.prod_name

  ami                         = var.prod_ami_id
  instance_type               = var.prod_instance_type
  availability_zone           = var.availability_zone
  subnet_id                   = element(module.vpc.private_subnets, 1)
  vpc_security_group_ids      = [module.prod-securtiy-group.security_group_id]
  key_name                    = data.aws_key_pair.prod.key_name
  associate_public_ip_address = false
  disable_api_stop            = false
  disable_api_termination     = false
  ebs_optimized               = true
  create_iam_instance_profile = false
  iam_instance_profile        = var.prod_iam_instance_profile
  #iam_role_name               = var.prod_iam_role_name
  #iam_role_description        = "IAM role for EC2 instance"
  #iam_role_policies           = var.prod_iam_role_policies
  metadata_options = {
    http_tokens                 = "required"
  }
  
  enable_volume_tags = false
  root_block_device = [
    {
      encrypted   = var.prod_root_encrypted
      kms_key_id  = module.kms_complete.key_arn
      volume_type = var.prod_volume_type
      volume_size = var.prod_volume_size
      tags = merge(
        {
          Name = "${var.prod_name}-(C:)"
        },
        var.prod_tags
      )
    }
  ]
  user_data = <<-EOF
    #!/bin/bash
    sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service
    sudo systemctl status snap.amazon-ssm-agent.amazon-ssm-agent.service
  EOF  
  #ebs_block_device = var.prod_ebs_block_devices

  tags = merge(
    {
      "dlcm"             = "yes",
      "wm-AutoStartStop" = "yes",
      "wm_backup"        = "yes"
    },
    var.prod_tags)
}