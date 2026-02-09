data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.name

  cluster_endpoint  = var.cluster_endpoint
  cluster_name      = var.cluster_name
  oidc_provider_arn = var.oidc_provider_arn

  iam_role_policy_prefix = "arn:${local.partition}:iam::aws:policy"
}
################################################################################
# Cluster Autoscaler
################################################################################

locals {
  cluster_autoscaler_service_account    = try(var.cluster_autoscaler.service_account_name, "cluster-autoscaler-sa")
  cluster_autoscaler_namespace          = try(var.cluster_autoscaler.namespace, "kube-system")
  cluster_autoscaler_image_tag_selected = try(local.cluster_autoscaler_image_tag[var.cluster_version], "v${var.cluster_version}.0")

  # Lookup map to pull latest cluster-autoscaler patch version given the cluster version
  cluster_autoscaler_image_tag = {
    "1.20" = "v1.20.3"
    "1.21" = "v1.21.3"
    "1.22" = "v1.22.3"
    "1.23" = "v1.23.1"
    "1.24" = "v1.24.3"
    "1.25" = "v1.25.3"
    "1.26" = "v1.26.6"
    "1.27" = "v1.27.5"
    "1.28" = "v1.28.2"
    "1.29" = "v1.29.0"
    "1.30" = "v1.30.2"
  }
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  count = var.enable_cluster_autoscaler ? 1 : 0

  source_policy_documents   = lookup(var.cluster_autoscaler, "source_policy_documents", [])
  override_policy_documents = lookup(var.cluster_autoscaler, "override_policy_documents", [])

  statement {
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeScalingActivities",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:DescribeInstanceTypes",
      "eks:DescribeNodegroup",
      "ec2:DescribeImages",
      "ec2:GetInstanceTypesFromInstanceRequirements"
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }
  }
}

module "cluster_autoscaler" {
  source = "../"

  create = var.enable_cluster_autoscaler

  # Disable helm release
  create_release = var.create_kubernetes_resources

  # https://github.com/kubernetes/autoscaler/blob/master/charts/cluster-autoscaler/Chart.yaml
  name             = try(var.cluster_autoscaler.name, "cluster-autoscaler")
  description      = try(var.cluster_autoscaler.description, "A Helm chart to deploy cluster-autoscaler")
  namespace        = local.cluster_autoscaler_namespace
  create_namespace = try(var.cluster_autoscaler.create_namespace, false)
  chart            = try(var.cluster_autoscaler.chart, "cluster-autoscaler")
  chart_version    = try(var.cluster_autoscaler.chart_version, "9.37.0")
  repository       = try(var.cluster_autoscaler.repository, "https://kubernetes.github.io/autoscaler")
  values           = try(var.cluster_autoscaler.values, [])

  timeout                    = try(var.cluster_autoscaler.timeout, null)
  repository_key_file        = try(var.cluster_autoscaler.repository_key_file, null)
  repository_cert_file       = try(var.cluster_autoscaler.repository_cert_file, null)
  repository_ca_file         = try(var.cluster_autoscaler.repository_ca_file, null)
  repository_username        = try(var.cluster_autoscaler.repository_username, null)
  repository_password        = try(var.cluster_autoscaler.repository_password, null)
  devel                      = try(var.cluster_autoscaler.devel, null)
  verify                     = try(var.cluster_autoscaler.verify, null)
  keyring                    = try(var.cluster_autoscaler.keyring, null)
  disable_webhooks           = try(var.cluster_autoscaler.disable_webhooks, null)
  reuse_values               = try(var.cluster_autoscaler.reuse_values, null)
  reset_values               = try(var.cluster_autoscaler.reset_values, null)
  force_update               = try(var.cluster_autoscaler.force_update, null)
  recreate_pods              = try(var.cluster_autoscaler.recreate_pods, null)
  cleanup_on_fail            = try(var.cluster_autoscaler.cleanup_on_fail, null)
  max_history                = try(var.cluster_autoscaler.max_history, null)
  atomic                     = try(var.cluster_autoscaler.atomic, null)
  skip_crds                  = try(var.cluster_autoscaler.skip_crds, null)
  render_subchart_notes      = try(var.cluster_autoscaler.render_subchart_notes, null)
  disable_openapi_validation = try(var.cluster_autoscaler.disable_openapi_validation, null)
  wait                       = try(var.cluster_autoscaler.wait, false)
  wait_for_jobs              = try(var.cluster_autoscaler.wait_for_jobs, null)
  dependency_update          = try(var.cluster_autoscaler.dependency_update, null)
  replace                    = try(var.cluster_autoscaler.replace, null)
  lint                       = try(var.cluster_autoscaler.lint, null)

  postrender = try(var.cluster_autoscaler.postrender, [])
  set = concat(
    [
      {
        name  = "awsRegion"
        value = local.region
      },
      {
        name  = "autoDiscovery.clusterName"
        value = local.cluster_name
      },
      {
        name  = "image.tag"
        value = local.cluster_autoscaler_image_tag_selected
      },
      {
        name  = "rbac.serviceAccount.name"
        value = local.cluster_autoscaler_service_account
      }
    ],
    try(var.cluster_autoscaler.set, [])
  )
  set_sensitive = try(var.cluster_autoscaler.set_sensitive, [])

  # IAM role for service account (IRSA)
  set_irsa_names                = ["rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"]
  create_role                   = try(var.cluster_autoscaler.create_role, true)
  role_name                     = try(var.cluster_autoscaler.role_name, "cluster-autoscaler")
  role_name_use_prefix          = try(var.cluster_autoscaler.role_name_use_prefix, false)
  role_path                     = try(var.cluster_autoscaler.role_path, "/")
  role_permissions_boundary_arn = lookup(var.cluster_autoscaler, "role_permissions_boundary_arn", null)
  role_description              = try(var.cluster_autoscaler.role_description, "IRSA for cluster-autoscaler operator")
  role_policies                 = lookup(var.cluster_autoscaler, "role_policies", {})

  source_policy_documents = data.aws_iam_policy_document.cluster_autoscaler[*].json
  policy_statements       = lookup(var.cluster_autoscaler, "policy_statements", [])
  policy_name             = try(var.cluster_autoscaler.policy_name, null)
  policy_name_use_prefix  = try(var.cluster_autoscaler.policy_name_use_prefix, false)
  policy_path             = try(var.cluster_autoscaler.policy_path, null)
  policy_description      = try(var.cluster_autoscaler.policy_description, "IAM Policy for cluster-autoscaler operator")

  oidc_providers = {
    this = {
      provider_arn = local.oidc_provider_arn
      # namespace is inherited from chart
      service_account = local.cluster_autoscaler_service_account
    }
  }

  tags = var.tags
}