# ######################################################
# # Defining Local variables
# ######################################################
module "eks_cluster" {

  source = "./modules/eks_module"

  create                                   = true
  cluster_name                             = "${var.eks_cluster_name}-${var.environment}-EKS-CLUSTER"
  cluster_version                          = var.eks_cluster_version
  cluster_endpoint_private_access          = var.eks_cluster_endpoint_private_access
  cluster_endpoint_public_access           = var.eks_cluster_endpoint_public_access
  cluster_ip_family                        = var.eks_cluster_ip_family
  enable_cluster_creator_admin_permissions = true          ### Grants cluster Admin access to the to the IAM principal (user or role) that creates the EKS cluster.
  cluster_endpoint_public_access_cidrs     = ["0.0.0.0/0"] ### Needed only when cluster_endpoint_public_access = true.
  cluster_enabled_log_types                = var.cluster_enabled_log_types
  # cluster_encryption_config = {       #### Need to use a different CMK.
  #   provider_key_arn = module.kms_complete.key_arn
  #   resources        = ["secrets"]
  # }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets                 #### Where the worker nodes (EC2 instances) will be deployed
  control_plane_subnet_ids = local.eks_vpc_private_controlPlane_subnets #### Where the EKS control plane will be deployed. It is recommended to use private subnets for control plane for better security.


  authentication_mode = var.eks_authentication_mode

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
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

  eks_managed_node_groups = {
    # This is for first node group 
    APPLICATION-NG = {
      name = "${var.eks_cluster_name}-${var.environment}-APPLICATION-NG"
      # ami_id                     = "${local.eks_ami_id}"   ### for testing
      ami_type                   = "AL2023_x86_64_STANDARD"
      enable_bootstrap_user_data = true
      # key_name                   = local.eks_nodegroup_key_name_app #### This is the SSH key for login into to worker node and this Needs to be created first.
      description          = "EKS Managed Node Group for APP"
      min_size             = 1
      max_size             = 3
      desired_size         = 1
      force_update_version = true
      instance_types       = "${var.app_instance_type}"
      labels = {
        role = "app"
      }
      node_repair_config = {
        enabled = true
      }
      # taints = {
      #   workload = {
      #     key    = "workload"
      #     value  = "crif-strategyone"
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
            volume_size = "${var.app_ebs_volume_size}"
            volume_type = "${var.app_ebs_volume_type}"
            iops        = 3000
            throughput  = 125
            encrypted   = true
            kms_key_id  = "${module.kms_complete.key_arn}"
            # kms_key_id            = local.eks_key_arn
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
      iam_role_name        = "${local.eks_app_node_role_ng}"
      iam_role_description = "EKS managed APPLICATION node group role"
      iam_role_tags = {
        "Implementedby" = "Workmates",
        "Managedby"     = "Workmates",
        "Layer"         = "IAM",
        "Environment"   = "PROD",
        "Project"       = "project"
      }
      iam_role_additional_policies = {
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        AmazonEBSCSIDriverPolicy           = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonEFSCSIDriverPolicy           = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
        AmazonSSMPolicy                    = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
        node_additional                    = aws_iam_policy.node_additional.arn
        node_kms_policy_attach             = aws_iam_policy.node-kms-policy.arn
      }
      launch_template_tags = {
        # enable discovery of autoscaling groups by cluster-autoscaler
        "k8s.io/cluster-autoscaler/enabled" : true,
        "k8s.io/cluster-autoscaler/${var.eks_cluster_name}-${var.environment}-EKS-CLUSTER" : "owned",
      }
      tags = merge(
        {
          "Name" : "${var.eks_cluster_name}-${var.environment}-EKS-APPLICATION-NG"
        },
        var.eks_tags
      )

    }

    # For a second node group just copy the above block and provide a diffrent name for the block.
    SERVICES-NG = {
      name = "${var.eks_cluster_name}-${var.environment}-SERVICES-NG"
      # ami_id                     = "${local.eks_ami_id}"   ### for testing
      ami_type                   = "AL2023_x86_64_STANDARD"
      enable_bootstrap_user_data = true
      # key_name                   = local.eks_nodegroup_key_name_service #### This is the SSH key for login into to worker node and this Needs to be created first.
      description          = "EKS Managed Node Group for SERVICES"
      min_size             = 1
      max_size             = 2
      desired_size         = 1
      force_update_version = true
      instance_types       = "${var.service_instance_type}"
      labels = {
        role = "service"
      }
      node_repair_config = {
        enabled = true
      }
      ebs_optimized           = true
      disable_api_termination = false
      #enable_monitoring       = true
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size = "${var.service_ebs_volume_size}"
            volume_type = "${var.service_ebs_volume_type}"
            iops        = 3000
            throughput  = 125
            encrypted   = true
            kms_key_id  = "${module.kms_complete.key_arn}"
            # kms_key_id            = "${local.eks_key_arn}"
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
      iam_role_name        = "${local.eks_service_node_role_ng}"
      iam_role_description = "EKS managed services node group  role"
      iam_role_tags = {
        "Implementedby" = "Workmates",
        "Managedby"     = "Workmates",
        "Layer"         = "IAM",
        "Environment"   = "PROD",
        "Project"       = "project"
      }
      iam_role_additional_policies = {
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        AmazonEBSCSIDriverPolicy           = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonEFSCSIDriverPolicy           = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
        AmazonSSMPolicy                    = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
        node_additional                    = aws_iam_policy.node_additional.arn
        node_kms_policy_attach             = aws_iam_policy.node-kms-policy.arn
      }
      launch_template_tags = {
        # enable discovery of autoscaling groups by cluster-autoscaler
        "k8s.io/cluster-autoscaler/enabled" : true,
        "k8s.io/cluster-autoscaler/${var.eks_cluster_name}-${var.environment}-EKS-CLUSTER" : "owned",
      }
      tags = merge(
        {
          "Name" : "${var.eks_cluster_name}-${var.environment}-EKS-SERVICES-NG"
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
      description = "Cluster Intra-VPC communication"
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
      principal_arn     = "arn:aws:iam::836397457870:role/Workmates-SSO-L2SupportRole"

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
      principal_arn     = "arn:aws:iam::836397457870:role/Workmates-SSO-AdminRole"

      policy_associations = {
        admin-view = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
    # Example of adding multiple policies to a single access entry
    ec2-role = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::836397457870:role/CWMManagedInstanceRole"

      policy_associations = {
        cluster-admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = var.eks_tags

}

################################
# Supporting Resources
################################
resource "aws_iam_policy" "node_additional" {
  name        = "${var.eks_cluster_name}-EKS-ADDITIONAL"
  description = " node additional policy for kms"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
          "kms:Decrypt",
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
        "Resource" : [module.kms_complete.key_arn],
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
        "Resource" : [module.kms_complete.key_arn]
      }
    ]
  })

  tags = var.eks_tags
}

