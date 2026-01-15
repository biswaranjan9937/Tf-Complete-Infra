module "uat-securtiy-group" {
  source      = "./modules/sg"
  name        = "${title(var.uat_name)}-SGs"
  description = "${title(var.uat_name)} Security group"
  vpc_id      = module.vpc.vpc_id
  ingress_rules = var.uat_ingress_rules
  egress_rules  = var.uat_egress_rules
}

module "uat" {
  count      = 1
  source     = "./modules/ec2"
  depends_on = [module.uat-securtiy-group, aws_s3_bucket.credential-bucket]
  create     = true
  name       = var.uat_name

  ami                         = var.uat_ami_id
  instance_type               = var.uat_instance_type
  availability_zone           = var.availability_zone
  subnet_id                   = element(module.vpc.private_subnets, 1)
  vpc_security_group_ids      = [module.uat-securtiy-group.security_group_id]
  key_name                    = aws_key_pair.uat_ec2_keypair.key_name
  associate_public_ip_address = false
  disable_api_stop            = false
  disable_api_termination     = false
  ebs_optimized               = true
  create_iam_instance_profile = false
  iam_instance_profile        = var.uat_iam_instance_profile
  #iam_role_name               = var.uat_iam_role_name
  #iam_role_description        = "IAM role for EC2 instance"
  #iam_role_policies           = var.uat_iam_role_policies
  metadata_options = {
    http_tokens                 = "required"
  }
  
  enable_volume_tags = false
  root_block_device = [
    {
      encrypted   = var.uat_root_encrypted
      kms_key_id  = module.kms_complete.key_arn
      volume_type = var.uat_volume_type
      volume_size = var.uat_volume_size
      tags = merge(
        {
          Name = "${var.uat_name}-(C:)"
        },
        var.uat_tags
      )
    }
  ]
  # user_data = templatefile("./scripts/user-creation-with-logs.sh")
  user_data = <<-EOF
  #!/bin/bash
  # Download and execute scripts

  # Copy scripts to temp location
  cat > /tmp/user-creation.sh << 'SCRIPT1'
  ${file("./scripts/user-uat.sh")}
  SCRIPT1

  cat > /tmp/cloudwatch.sh << 'SCRIPT2'
  ${file("./scripts/cloud-watch.sh")}
  SCRIPT2

  # Make executable and run
  chmod +x /tmp/user-creation.sh /tmp/cloudwatch.sh
  ./tmp/user-creation.sh
  ./tmp/cloudwatch.sh
  EOF

  tags = merge(
    {
      "dlcm"             = "yes",
      "wm-AutoStartStop" = "yes",
      "wm_backup"        = "yes"
    },
    var.uat_tags)
}