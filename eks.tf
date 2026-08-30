# ######################################################
# # Defining Local variables
# ######################################################
module "eks_cluster" {

  source = "./modules/eks_module"

  create                                   = true
  cluster_name                             = local.cluster_name
  cluster_version                          = var.eks_cluster_version
  cluster_endpoint_private_access          = var.eks_cluster_endpoint_private_access
  cluster_endpoint_public_access           = var.eks_cluster_endpoint_public_access
  cluster_ip_family                        = var.eks_cluster_ip_family
  enable_cluster_creator_admin_permissions = true          ### Grants cluster Admin access to the to the IAM principal (user or role) that creates the EKS cluster.
  cluster_endpoint_public_access_cidrs     = ["0.0.0.0/0"] ### Needed only when cluster_endpoint_public_access = true.
  cluster_enabled_log_types                = var.cluster_enabled_log_types
  # cluster_encryption_config = {       #### Need to use a different CMK.
  #   provider_key_arn = module.aws_cmk.key_arn
  #   resources        = ["secrets"]
  # }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets #### Where the worker nodes (EC2 instances) will be deployed
  control_plane_subnet_ids = module.vpc.private_subnets #### Where the EKS control plane will be deployed. It is recommended to use private subnets for control plane for better security.


  authentication_mode = var.eks_authentication_mode


  ### Note: Other addons like metrics-server, ebs-csi-driver and efs-csi-driver will be installed as part of eks-addons using helm charts after the cluster is created. This is because these addons require additional configuration and permissions that are easier to manage separately.
  cluster_addons = {
    coredns = { ### Enables service discovery for applications running in the cluster and is required for cluster functionality.
      most_recent = true
    }
    kube-proxy = { ### This will forward the traffic to right pod based on the service and endpoint information. It is required for cluster functionality.
      most_recent = true
    }
    vpc-cni = { ### It assigns IP addresses to pods and manages network connectivity for pods. It is required for cluster functionality.
      most_recent    = true
      before_compute = true
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }


  #### Node Group Configurations
  eks_managed_node_groups = {
    # This is for first node group 
    APPLICATION-NG = {
      # name                       = "${local.cluster_name}-APPLICATION-NG"
      name                       = "${local.app_node_group_name}"
      ami_type                   = "AL2023_x86_64_STANDARD"
      enable_bootstrap_user_data = false                                    ## This is not needed for EKS managed AMI
      key_name                   = aws_key_pair.eks_app_ng_keypair.key_name #### This is the SSH key for login into to worker node and this Needs to be created first.
      description                = "EKS Managed Node Group for Application workloads"
      min_size                   = var.app_ng_min_size
      max_size                   = var.app_ng_max_size
      desired_size               = var.app_ng_desired_size
      force_update_version       = true
      instance_types             = "${var.app_ng_instance_type}"

      labels = {
        role = "app"
      }

      node_repair_config = {
        enabled = true
      }

      # taints = {
      #   workload = {
      #     key    = "workload"
      #     value  = "app"
      #     effect = "NO_SCHEDULE"
      #   }
      # }

      ebs_optimized           = true
      disable_api_termination = false
      #enable_monitoring       = true
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = "${var.app_ng_ebs_volume_size}"
            volume_type           = "${var.app_ng_ebs_volume_type}"
            iops                  = 3000
            throughput            = 125
            encrypted             = true
            kms_key_id            = "${module.aws_cmk.key_arn}"
            delete_on_termination = true
          }
        }
      }

      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
        instance_metadata_tags      = "disabled"
      }

      create_iam_role      = true
      iam_role_name        = "${local.app_ng_role_name}"
      iam_role_description = "IAM Role for EKS Managed Application NG"
      iam_role_tags = merge(var.eks_tags, {
        Name = "Application-NG"
      })
      iam_role_additional_policies = {
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        AmazonSSMPolicy                    = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
        node_additional                    = aws_iam_policy.node_additional.arn
      }
      launch_template_tags = {
        # enable discovery of autoscaling groups by cluster-autoscaler
        "k8s.io/cluster-autoscaler/enabled" : true,
        "k8s.io/cluster-autoscaler/${local.cluster_name}" : "owned",
      }
      tags = merge(
        {
          Name : "${local.cluster_name}-Application-NG",
          Environment : var.environment,
          Project : var.project_name
        },
        var.eks_tags
      )

    }

    # For a second node group just copy the above block and provide a diffrent name for the block.
    SERVICES-NG = {
      # name                       = "${local.cluster_name}-SERVICES-NG"
      name                       = "${local.svc_node_group_name}"
      ami_type                   = "AL2023_x86_64_STANDARD"
      enable_bootstrap_user_data = false ## This is not needed for EKS managed AMI
      # key_name                   = local.eks_nodegroup_key_name_service #### This is the SSH key for login into to worker node and this Needs to be created first.
      key_name             = aws_key_pair.eks_svc_ng_keypair.key_name
      description          = "EKS Managed Node Group for SERVICES"
      min_size             = var.svc_ng_min_size
      max_size             = var.svc_ng_max_size
      desired_size         = var.svc_ng_desired_size
      force_update_version = true
      instance_types       = "${var.svc_ng_instance_type}"

      labels = {
        role = "service"
      }

      node_repair_config = {
        enabled = true
      }
      # taints = {
      #   workload = {
      #     key    = "workload"
      #     value  = "service"
      #     effect = "NO_SCHEDULE"
      #   }
      # }
      ebs_optimized           = true
      disable_api_termination = false
      #enable_monitoring       = true
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = "${var.svc_ng_ebs_volume_size}"
            volume_type           = "${var.svc_ng_ebs_volume_type}"
            iops                  = 3000
            throughput            = 125
            encrypted             = true
            kms_key_id            = "${module.aws_cmk.key_arn}"
            delete_on_termination = true
          }
        }
      }
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
        instance_metadata_tags      = "disabled"
      }

      create_iam_role      = true
      iam_role_name        = "${local.svc_ng_role_name}"
      iam_role_description = "IAM Role for EKS Managed Service NG"
      iam_role_tags = merge(var.eks_tags, {
        Name = "Service-NG"
      })
      iam_role_additional_policies = {
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        AmazonSSMPolicy                    = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
        node_additional                    = aws_iam_policy.node_additional.arn
      }
      launch_template_tags = {
        # enable discovery of autoscaling groups by cluster-autoscaler
        "k8s.io/cluster-autoscaler/enabled" : true,
        "k8s.io/cluster-autoscaler/${local.cluster_name}" : "owned",
      }
      tags = merge(
        {
          Name : "${local.cluster_name}-Service-NG",
          Environment : var.environment,
          Project : var.project_name
        },
        var.eks_tags
      )

    }


    MONITORING-NG = {
      # name                       = "${local.cluster_name}-SERVICES-NG"
      name                       = "${local.mon_node_group_name}"
      ami_type                   = "AL2023_x86_64_STANDARD"
      enable_bootstrap_user_data = false ## This is not needed for EKS managed AMI
      # key_name                   = local.eks_nodegroup_key_name_service #### This is the SSH key for login into to worker node and this Needs to be created first.
      key_name             = aws_key_pair.eks_mon_ng_keypair.key_name
      description          = "EKS Managed Node Group for Monitoring"
      min_size             = var.mon_ng_min_size
      max_size             = var.mon_ng_max_size
      desired_size         = var.mon_ng_desired_size
      force_update_version = true
      instance_types       = "${var.mon_ng_instance_type}"
      subnet_ids           = [module.vpc.private_subnets[1]] # subnet of ap-south-1b az


      labels = {
        role = "monitoring"
      }

      node_repair_config = {
        enabled = true
      }
      taints = {
        workload = {
          key    = "workload"
          value  = "monitoring"
          effect = "NO_SCHEDULE"
        }
      }
      ebs_optimized           = true
      disable_api_termination = false
      #enable_monitoring       = true
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = "${var.mon_ng_ebs_volume_size}"
            volume_type           = "${var.mon_ng_ebs_volume_type}"
            iops                  = 3000
            throughput            = 125
            encrypted             = true
            kms_key_id            = "${module.aws_cmk.key_arn}"
            delete_on_termination = true
          }
        }
      }
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
        instance_metadata_tags      = "disabled"
      }

      create_iam_role      = true
      iam_role_name        = "${local.mon_ng_role_name}"
      iam_role_description = "IAM Role for EKS Managed Monitoring NG"
      iam_role_tags = merge(var.eks_tags, {
        Name = "Monitoring-NG"
      })
      iam_role_additional_policies = {
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        AmazonSSMPolicy                    = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
        node_additional                    = aws_iam_policy.node_additional.arn
      }
      launch_template_tags = {
        # enable discovery of autoscaling groups by cluster-autoscaler
        "k8s.io/cluster-autoscaler/enabled" : true,
        "k8s.io/cluster-autoscaler/${local.cluster_name}" : "owned",
      }
      tags = merge(
        {
          Name : "${local.cluster_name}-Monitoring-NG",
          Environment : var.environment,
          Project : var.project_name
        },
        var.eks_tags
      )

    }

  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1" ### This means all protocols. You can specify "tcp", "udp" or "icmp" if you want to restrict to specific protocol.
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true ### This allows nodes to communicate with each other on all ports and protocols, which is often necessary for Kubernetes components to function properly.
    }
    egress_all = {
      description = "Node all egress"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }

  }

  ## Enable access from bastion host to EKS endpoint
  cluster_security_group_additional_rules = {
    ingress_443 = {
      description = "Allow access from bastion host to EKS API server"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
    egress_all = {
      description = "Egress for cluster SG"
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  access_entries = {
    # One access entry with a policy associated
    l2-support-role = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::675169529857:role/Workmates-SSO-L2SupportRole"

      policy_associations = {
        admin-view = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
    admin-support-role = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::675169529857:role/Workmates-SSO-AdminRole"

      policy_associations = {
        admin-view = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
    # # Example of adding multiple policies to a single access entry
    # ec2-role = {
    #   kubernetes_groups = []
    #   principal_arn     = "arn:aws:iam::675169529857:role/CWMManagedInstanceRole"

    #   policy_associations = {
    #     cluster-admin = {
    #       policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    #       access_scope = {
    #         type = "cluster"
    #       }
    #     }
    #   }
    # }
  }

  tags = merge(var.eks_tags, {
    Environment = var.environment,
    Project     = var.project_name
  })

}

################################
# Supporting Resources
################################
resource "aws_iam_policy" "node_additional" {
  name        = "${local.cluster_name}-Additional-Node-Policy"
  description = "Additional node policy for KMS access and EFS access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
          "s3:GetEncryptionConfiguration",
          "efs:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ],
        "Resource" : [module.aws_cmk.key_arn],
        "Condition" : {
          "Bool" : {
            "kms:GrantIsForAWSResource" : "true"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : [module.aws_cmk.key_arn]
      }
    ]
  })

  tags = merge(var.eks_tags, {
    Environment = var.environment,
    Project     = var.project_name
  })
}