################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "./modules/VPC"

  name = local.vpc_name
  cidr = var.vpc_cidr

  azs              = local.azs
  private_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k + 1)]
  public_subnets   = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k + 4)]
  database_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k + 7)]

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1,
    "Tier"                   = "Public"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "Tier"                            = "Private"
  }

  database_subnet_tags = {
    "Tier" = "Database"
  }


  single_nat_gateway = var.single_nat_gateway
  enable_nat_gateway = var.enable_nat_gateway

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support ### This is the DNS resolutions.

  enable_flow_log           = true
  flow_log_destination_type = "s3"
  flow_log_destination_arn  = module.vpc-flowlog-bucket.s3_bucket_arn

  tags = var.vpc_tags
}

resource "aws_s3_bucket_lifecycle_configuration" "vpc_flowlog_lifecycle" {
  bucket = module.vpc-flowlog-bucket.s3_bucket_id

  rule {
    id     = "${var.Project_Name}_vpc_flowlogs_lifecycle"
    status = "Enabled"
    filter {
      prefix = "" ### Apply to all objects
    }
    expiration {
      days = 15 ### Expire objects after 15 days
    }
  }
}
# #####################################################
# # VPC Endpoints
# #####################################################
## Route Tables for S3 Gateway
module "vpc_endpoints" {
  source = "./modules/VPC/vpc-endpoints"

  create = true
  vpc_id = module.vpc.vpc_id

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = [module.vpc.private_route_table_ids[0], module.vpc.public_route_table_ids[0]]
      tags            = { Name = "${local.vpc_name}-S3-Endpoint" }
    }
  }

  tags = merge(var.vpc_tags, {
    Endpoint = "true"
  })
}

# ####################################################################
# # PRITUNL
# ####################################################################

module "pritunl-securtiy-group" {
  source      = "./modules/sg"
  name        = "${upper(local.ec2_pritunl_name)}-SG"
  description = "${upper(local.ec2_pritunl_name)} Security group"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = var.ec2_pritunl_ingress_rules
  egress_rules  = var.ec2_pritunl_egress_rules
}

module "ec2_pritunl" {
  source     = "./modules/ec2"
  depends_on = [module.pritunl-securtiy-group, module.vpn_credential_bucket]
  create     = true
  name       = local.ec2_pritunl_name

  ami                         = var.ec2_pritunl_ami_id
  instance_type               = var.ec2_pritunl_instance_type
  availability_zone           = element(module.vpc.azs, 0)
  subnet_id                   = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids      = [module.pritunl-securtiy-group.security_group_id]
  key_name                    = aws_key_pair.vpn_ec2_keypair.key_name
  associate_public_ip_address = true
  disable_api_stop            = false
  disable_api_termination     = var.ec2_pritunl_termination_protection
  ebs_optimized               = true
  source_dest_check           = false
  create_iam_instance_profile = true #### make it false if you already have Instance profile. Also comment iam_role_policies.
  iam_role_policies = {
    AmazonSSMManagedInstanceCore               = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonEC2ContainerRegistryS3ReadOnlyAccess = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  }
  # iam_instance_profile        = var.ec2_pritunl_iam_instance_profile   ### Uncomment this if you already have Instance profile.

  enable_volume_tags = false
  root_block_device = [
    {
      encrypted   = var.ec2_pritunl_root_encrypted
      kms_key_id  = local.ec2_pritunl_kms_key_id
      volume_type = var.ec2_pritunl_volume_type
      volume_size = var.ec2_pritunl_volume_size
      tags = {
        Name = "${local.ec2_pritunl_name}-OS"
      }
    }
  ]
  # ebs_block_device = [
  #   {
  #     device_name = "/dev/sdf"
  #     volume_type = "gp3"
  #     volume_size = 30
  #     encrypted   = true
  #     kms_key_id  = local.ec2_pritunl_kms_key_id
  #     tags = merge(
  #       {
  #         Name = "${local.ec2_pritunl_name}-DATA"
  #       },
  #       local.ec2_pritunl_tags
  #     )
  #   }
  # ]

  user_data = templatefile("./scripts/pritunl-ubuntu24.04.sh", { S3_BUCKET_NAME = module.vpn_credential_bucket.s3_bucket_id })

  tags = var.ec2_pritunl_tags
}

# ################################
# # PRITUNL Supoorting resources
# ################################

resource "aws_eip" "vpn-eip" {
  domain = "vpc"

  instance = module.ec2_pritunl.id
  tags = merge(
    {
      Name = "${local.ec2_pritunl_name}-EIP"
    },
    var.ec2_pritunl_tags
  )
}

