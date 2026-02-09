module "runner-securtiy-group" {
  source        = "./modules/sg"
  name          = "${title(var.runner_name)}-SGs"
  description   = "${title(var.runner_name)} Security group"
  vpc_id        = module.vpc.vpc_id
  ingress_rules = var.runner_ingress_rules
  egress_rules  = var.runner_egress_rules
}

module "runner" {
  count      = 1
  source     = "./modules/ec2"
  depends_on = [module.runner-securtiy-group, module.vpn_credential_bucket]
  create     = true
  name       = var.runner_name

  ami                         = var.runner_ami_id
  instance_type               = var.runner_instance_type
  availability_zone           = var.availability_zone
  subnet_id                   = element(module.vpc.private_subnets, 1)
  vpc_security_group_ids      = [module.runner-securtiy-group.security_group_id]
  key_name                    = aws_key_pair.runner_ec2_keypair.key_name
  associate_public_ip_address = false
  disable_api_stop            = false
  disable_api_termination     = false
  ebs_optimized               = true
  create_iam_instance_profile = true
  iam_role_policies = {
    AmazonSSMManagedInstanceCore               = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonEC2ContainerRegistryS3ReadOnlyAccess = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  }
  #   iam_instance_profile        = var.runner_iam_instance_profile
  #iam_role_name               = var.runner_iam_role_name
  #iam_role_description        = "IAM role for EC2 instance"
  #iam_role_policies           = var.runner_iam_role_policies
  metadata_options = {
    http_tokens = "required"
  }

  enable_volume_tags = false
  root_block_device = [
    {
      encrypted   = var.runner_root_encrypted
      kms_key_id  = module.kms_complete.key_arn
      volume_type = var.runner_volume_type
      volume_size = var.runner_root_volume_size
      tags = merge(
        {
          Name = "${var.runner_name}-root(/)"
        },
        var.runner_tags
      )
    }
  ]

  user_data = templatefile("./scripts/runner.sh")
  #   user_data = <<-EOF
  #   #!/bin/bash
  #   # Download and execute scripts

  #   # Copy scripts to temp location
  #   cat > /tmp/user-creation.sh << 'SCRIPT1'
  #   ${file("./scripts/user-runner.sh")}
  #   SCRIPT1

  #   cat > /tmp/cloudwatch.sh << 'SCRIPT2'
  #   ${file("./scripts/cloud-watch.sh")}
  #   SCRIPT2

  #   # Make executable and run
  #   chmod +x /tmp/user-creation.sh /tmp/cloudwatch.sh
  #   ./tmp/user-creation.sh
  #   ./tmp/cloudwatch.sh
  #   EOF

  tags = merge(
    {
      "dlcm"             = "yes",
      "wm-AutoStartStop" = "yes",
      "wm_backup"        = "yes"
    },
  var.runner_tags)
}