########################################
# IAM Role for Load Balancer Controller
########################################

# resource "aws_iam_policy" "lbc_policy" {
#   name        = "AWSLoadBalancerControllerIAMPolicy"
#   description = "Permissions for AWS Load Balancer Controller to manage ALBs/NLBs"
#   policy = file("${path.module}/iam_policy_for_lbc.json")
# }

# resource "aws_iam_role" "lbc_role" {
#   name = "${var.Project_Name}-${var.environment}-aws-lbc-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Effect = "Allow"
#         Principal = {
#           Federated = "${module.eks_cluster.oidc_provider_arn}"
#         }
#         Condition = {
#           StringEquals = {
#             "${module.eks_cluster.oidc_provider}:aud" : "sts.amazonaws.com"
#           }
#         }
#       }
#     ]
#   })

#   depends_on = [ aws_iam_policy.lbc_policy ]
# }

# resource "aws_iam_role_policy_attachment" "lbc_policy_attach" {
#   policy_arn = aws_iam_policy.lbc_policy.arn
#   role       = aws_iam_role.lbc_role.name

#   depends_on = [ aws_iam_role.lbc_role ]
# }



#####################################
# IAM Role for Cluster Autoscaler
#####################################

# resource "aws_iam_role" "ca_role" {
#   name = "${var.Project_Name}-${var.environment}-cluster-autoscaler"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Federated = "${module.eks_cluster.oidc_provider_arn}"
#         }
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Condition = {
#           StringEquals = {
#             "${module.eks_cluster.oidc_provider}:aud" : "sts.amazonaws.com"
#           }
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "ca_policy_attach" {
#   policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
#   role       = aws_iam_role.ca_role.name

#   depends_on = [ aws_iam_role.ca_role ]
# }



#######################################
# IAM Role for EBS CSI Driver
#######################################

resource "aws_iam_role" "ebs_csi_driver_role" {
  name = "${var.Project_Name}-${var.environment}-ebs-csi-driver"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "${module.eks_cluster.oidc_provider_arn}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${module.eks_cluster.oidc_provider}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy_attach" {
  role       = aws_iam_role.ebs_csi_driver_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}



#################################
# IAM Role for EFS CSI Driver
#################################

resource "aws_iam_role" "efs_csi_driver_role" {
  name = "${var.Project_Name}-${var.environment}-efs-csi-driver"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "${module.eks_cluster.oidc_provider_arn}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${module.eks_cluster.oidc_provider}:sub" = "system:serviceaccount:kube-system:efs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "efs_csi_driver_policy_attach" {
  role       = aws_iam_role.efs_csi_driver_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"

  depends_on = [aws_iam_role.efs_csi_driver_role]
}



###################################
# IAM Policy for EBS KMS Access
###################################

resource "aws_iam_policy" "ebs-kms-policy" {
  name        = "${var.Project_Name}-${var.environment}-ebs-kms"
  path        = "/"
  description = "ebs-kms-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_kms_policy_attach" {
  policy_arn = aws_iam_policy.ebs-kms-policy.arn
  role       = aws_iam_role.ebs_csi_driver_role.name

  depends_on = [aws_iam_role.ebs_csi_driver_role]
}



###################################
# IAM Policy for Node KMS Access
###################################

resource "aws_iam_policy" "node-kms-policy" {
  name        = "${var.Project_Name}-${var.environment}-node-kms"
  path        = "/"
  description = "IAM Policy for Node KMS Access"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# resource "aws_iam_role_policy_attachment" "node_kms_policy_attach1" {
#   policy_arn = aws_iam_policy.node-kms-policy.arn
#   role       = local.eks_app_node_role_ng

#   depends_on = [ module.eks_cluster ]
# }
# resource "aws_iam_role_policy_attachment" "node_kms_policy_attach2" {
#   policy_arn = aws_iam_policy.node-kms-policy.arn
#   role       = local.eks_service_node_role_ng

#   depends_on = [ module.eks_cluster ]
# }
