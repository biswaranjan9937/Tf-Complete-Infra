# ########################################################################
# # AWS Load Balancer Controller
# ########################################################################
# module "aws_lb_controller" {
#   source = "./modules/eks_module/addons/blueprints/aws_lb_controller"

#   enable_aws_load_balancer_controller = true
#   # Set to False To disable helm release 
#   create_kubernetes_resources = true

#   aws_load_balancer_controller = {
#     name             = "aws-lb-controller"
#     namespace        = "kube-system"
#     create_namespace = true
#     chart            = "aws-load-balancer-controller"
#     chart_version    = "1.12.0"
#     repository       = "https://aws.github.io/eks-charts"
#     timeout          = 180

#     values = [
#       templatefile("./values-files/aws_lb_contoller_values.yaml", {
#         # annotations = "eks.amazonaws.com/role-arn: ${aws_iam_role.lbc_role.arn}", #### Ignore this if your create_role is true.
#         tolerations = yamlencode([
#           {
#             key      = "workload"
#             operator = "Equal"
#             value    = "crif"
#             effect   = "NoSchedule"
#           }
#         ]),
#         cluster_name = module.eks_cluster.cluster_name,
#         region       = var.region,
#         vpcID        = module.vpc.vpc_id,
#       })
#     ]
#     set = [] #### To override chart values at install/upgrade time without editing values.yaml

#     create_role = true
#     role_name   = var.aws_lbc_role

#     tags = var.eks_tags
#     # tags = {
#     #   "ENVIRONMENT"   = "PROD"
#     #   "PROJECT"       = "INCEDE"
#     #   "Implementedby" = "Workmates"
#     #   "Managedby"     = "Workmates"
#     # }
#   }

#   cluster_name      = module.eks_cluster.cluster_name
#   cluster_version   = module.eks_cluster.cluster_version
#   cluster_endpoint  = module.eks_cluster.cluster_endpoint
#   oidc_provider_arn = module.eks_cluster.oidc_provider_arn

#   # depends_on = [ aws_iam_role.lbc_role ]    #### Ignore this if your create_role is true.
# }

# ########################################################################
# #  Cluster Autoscaler
# ########################################################################
# module "cluster_autoscaler" {
#   source = "./modules/eks_module/addons/blueprints/cluster_autoscaler"

#   enable_cluster_autoscaler = true
#   # Set to False To disable helm release 
#   create_kubernetes_resources = true

#   cluster_autoscaler = {
#     name             = "cluster-autoscaler"
#     namespace        = "kube-system"
#     create_namespace = true
#     chart            = "cluster-autoscaler"
#     chart_version    = "9.46.2"
#     repository       = "https://kubernetes.github.io/autoscaler"
#     timeout          = 300

#     values = [
#       templatefile("./values-files/cluster_autoscaler_values.yaml", {
#         cluster_name   = module.eks_cluster.cluster_name,
#         region         = var.region,
#         cloud_provider = var.cloud_provider,
#         # annotations    = "eks.amazonaws.com/role-arn: ${aws_iam_role.ca_role.arn}", #### Ignore this if your create_role is true.
#         tolerations = yamlencode([
#           {
#             key      = "workload"
#             operator = "Equal"
#             value    = "crif"
#             effect   = "NoSchedule"
#           }
#         ]),
#       })
#     ]
#     set = [ #### To override chart values at install/upgrade time without editing values.yaml
#       {
#         name  = "replicaCount"
#         value = "1"
#       }
#     ]

#     create_role = true
#     role_name   = var.ca_role

#     tags = var.eks_tags

#     # tags = {
#     #   "ENVIRONMENT"   = "POC"
#     #   "PROJECT"       = "INCEDE"
#     #   "Implementedby" = "Workmates"
#     #   "Managedby"     = "Workmates"
#     # }

#   }

#   cluster_name      = module.eks_cluster.cluster_name
#   cluster_version   = module.eks_cluster.cluster_version
#   cluster_endpoint  = module.eks_cluster.cluster_endpoint
#   oidc_provider_arn = module.eks_cluster.oidc_provider_arn

#   # depends_on = [ aws_iam_role.ca_role ]   #### Ignore this if your create_role is true.
#   depends_on = [module.aws_lb_controller]

# }
# ########################################################################
# # Metric Server
# ########################################################################
# module "metrics_server" {
#   source = "./modules/eks_module/addons/blueprints/metric_server"

#   enable_metrics_server = true
#   # Set to False To disable helm release 
#   create_kubernetes_resources = true

#   metrics_server = {
#     name             = "metrics-server"
#     namespace        = "kube-system"
#     create_namespace = true
#     chart            = "metrics-server"
#     chart_version    = "3.12.0"
#     repository       = "https://kubernetes-sigs.github.io/metrics-server/"
#     timeout          = 180

#     values = [
#       templatefile("./values-files/metric_server_values.yaml", {
#         # annotations = "eks.amazonaws.com/role-arn: ${var.iam_role_arn}", #### Ignore this if your create_role is true.
#         tolerations = yamlencode([
#           {
#             key      = "workload"
#             operator = "Equal"
#             value    = "crif"
#             effect   = "NoSchedule"
#           }
#         ]),
#       })
#     ]
#     set = [] #### To override chart values at install/upgrade time without editing values.yaml

#     create_role = true
#     role_name   = var.metric_server_role

#     tags = var.eks_tags
#     # tags = {
#     #   "ENVIRONMENT"   = "POC"
#     #   "PROJECT"       = "INCEDE"
#     #   "Implementedby" = "Workmates"
#     #   "Managedby"     = "Workmates"
#     # }

#   }

#   cluster_name      = module.eks_cluster.cluster_name
#   cluster_version   = module.eks_cluster.cluster_version
#   cluster_endpoint  = module.eks_cluster.cluster_endpoint
#   oidc_provider_arn = module.eks_cluster.oidc_provider_arn

#   depends_on = [module.aws_lb_controller]

# }

# ####################################################
# # EBS_CSI Driver
# ####################################################
# # Above defined toleration is not working for ebs-csi driver and efs-csi driver.
# resource "helm_release" "ebs_csi" {
#   name       = "aws-ebs-csi-driver"
#   repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver/"
#   chart      = "aws-ebs-csi-driver"
#   version    = "2.34.0"    #### Latest working version of aws-ebs-csi-driver helm chart version
#   namespace  = "kube-system"
#   set {
#     name  = "controller.replicaCount"
#     value = "1"
#   }
#   values = [
#     templatefile("./values-files/ebs_csi_driver_values.yaml", {
#       role_arn = "${aws_iam_role.ebs_csi_driver_role.arn}"
#     })
#   ]

#   depends_on = [aws_iam_role.ebs_csi_driver_role, module.eks_cluster]
# }


# # gp3 storgae class addition
# resource "kubectl_manifest" "gp3_sc" {
#   yaml_body = templatefile("./manifest-files/ebs/ebs_gp3_sc.yaml", {
#     kms-id = module.kms_complete.key_arn
#   })
#   depends_on = [helm_release.ebs_csi]
# }

# ######################################################
# # EFS_CSI Driver 
# ######################################################
# resource "helm_release" "efs_csi" {
#   name       = "aws-efs-csi-driver"
#   repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
#   chart      = "aws-efs-csi-driver"
#   version    = "3.4.0"    #### Latest working version of aws-efs-csi-driver helm chart version
#   namespace  = "kube-system"

#   set {
#     name  = "controller.replicaCount"
#     value = "1"
#   }
#   values = [
#     templatefile("./values-files/efs_csi_driver_values.yaml", {
#       role_arn = "${aws_iam_role.efs_csi_driver_role.arn}"
#     })
#   ]

#   depends_on = [aws_iam_role.efs_csi_driver_role, module.eks_cluster]
# }

# # need to make the efs file-system id passing as dynamic.
# # resource "kubectl_manifest" "efs_sc" {
# #   yaml_body  = file("./manifest-files/efs/efs_sc.yaml")
# #   depends_on = [helm_release.efs_csi]
# # }
# resource "kubectl_manifest" "efs_sc" {
#   yaml_body = templatefile("./manifest-files/efs/efs_sc.yaml", {
#     fileSystemId = module.efs.id
#   })
#   depends_on = [helm_release.efs_csi, module.efs]
# }

