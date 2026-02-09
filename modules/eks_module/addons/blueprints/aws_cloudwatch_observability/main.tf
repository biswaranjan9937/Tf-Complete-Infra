################################################################################
# AWS Cloudwatch Metrics
################################################################################

locals {
  aws_cloudwatch_observability_service_account = try(var.aws_cloudwatch_observability.service_account_name, "amazon-cloudwatch-observability")
  aws_cloudwatch_observability_namespace       = try(var.aws_cloudwatch_observability.namespace, "amazon-cloudwatch")


  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.name

  cluster_endpoint  = var.cluster_endpoint
  cluster_name      = var.cluster_name
  oidc_provider_arn = var.oidc_provider_arn
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "aws_cloudwatch_observability" {
  source = "../"

  create = var.enable_aws_cloudwatch_observability

  # Disable helm release
  create_release = var.create_kubernetes_resources

  # https://github.com/aws/eks-charts/tree/master/stable/aws-cloudwatch-metrics
  name             = try(var.aws_cloudwatch_observability.name, "amazon-cloudwatch-observability")
  description      = try(var.aws_cloudwatch_observability.description, "A Helm chart to deploy amazon-cloudwatch-observability project")
  namespace        = local.aws_cloudwatch_observability_namespace
  create_namespace = try(var.aws_cloudwatch_observability.create_namespace, true)
  chart            = try(var.aws_cloudwatch_observability.chart, "amazon-cloudwatch-observability")
  chart_version    = try(var.aws_cloudwatch_observability.chart_version, "3.2.0")
  repository       = try(var.aws_cloudwatch_observability.repository, "https://aws-observability.github.io/helm-charts")
  values           = try(var.aws_cloudwatch_observability.values, [])

  timeout                    = try(var.aws_cloudwatch_observability.timeout, null)
  repository_key_file        = try(var.aws_cloudwatch_observability.repository_key_file, null)
  repository_cert_file       = try(var.aws_cloudwatch_observability.repository_cert_file, null)
  repository_ca_file         = try(var.aws_cloudwatch_observability.repository_ca_file, null)
  repository_username        = try(var.aws_cloudwatch_observability.repository_username, null)
  repository_password        = try(var.aws_cloudwatch_observability.repository_password, null)
  devel                      = try(var.aws_cloudwatch_observability.devel, null)
  verify                     = try(var.aws_cloudwatch_observability.verify, null)
  keyring                    = try(var.aws_cloudwatch_observability.keyring, null)
  disable_webhooks           = try(var.aws_cloudwatch_observability.disable_webhooks, null)
  reuse_values               = try(var.aws_cloudwatch_observability.reuse_values, null)
  reset_values               = try(var.aws_cloudwatch_observability.reset_values, null)
  force_update               = try(var.aws_cloudwatch_observability.force_update, null)
  recreate_pods              = try(var.aws_cloudwatch_observability.recreate_pods, null)
  cleanup_on_fail            = try(var.aws_cloudwatch_observability.cleanup_on_fail, null)
  max_history                = try(var.aws_cloudwatch_observability.max_history, null)
  atomic                     = try(var.aws_cloudwatch_observability.atomic, null)
  skip_crds                  = try(var.aws_cloudwatch_observability.skip_crds, null)
  render_subchart_notes      = try(var.aws_cloudwatch_observability.render_subchart_notes, null)
  disable_openapi_validation = try(var.aws_cloudwatch_observability.disable_openapi_validation, null)
  wait                       = try(var.aws_cloudwatch_observability.wait, false)
  wait_for_jobs              = try(var.aws_cloudwatch_observability.wait_for_jobs, null)
  dependency_update          = try(var.aws_cloudwatch_observability.dependency_update, null)
  replace                    = try(var.aws_cloudwatch_observability.replace, null)
  lint                       = try(var.aws_cloudwatch_observability.lint, null)

  postrender = try(var.aws_cloudwatch_observability.postrender, [])
  set = concat(
    [
      {
        name  = "clusterName"
        value = local.cluster_name
      },
      {
        name  = "serviceAccount.name"
        value = local.aws_cloudwatch_observability_service_account
      }
    ],
    try(var.aws_cloudwatch_observability.set, [])
  )
  set_sensitive = try(var.aws_cloudwatch_observability.set_sensitive, [])

  # IAM role for service account (IRSA)
  set_irsa_names                = ["serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"]
  create_role                   = try(var.aws_cloudwatch_observability.create_role, true)
  role_name                     = try(var.aws_cloudwatch_observability.role_name, "aws-cloudwatch-observability")
  role_name_use_prefix          = try(var.aws_cloudwatch_observability.role_name_use_prefix, true)
  role_path                     = try(var.aws_cloudwatch_observability.role_path, "/")
  role_permissions_boundary_arn = try(var.aws_cloudwatch_observability.role_permissions_boundary_arn, null)
  role_description              = try(var.aws_cloudwatch_observability.role_description, "IRSA for aws-cloudwatch-obeservability project")
  role_policies = lookup(var.aws_cloudwatch_observability, "role_policies",
    { CloudWatchAgentServerPolicy = "arn:${local.partition}:iam::aws:policy/CloudWatchAgentServerPolicy" }
  )
  create_policy = try(var.aws_cloudwatch_observability.create_policy, false)

  oidc_providers = {
    this = {
      provider_arn = local.oidc_provider_arn
      # namespace is inherited from chart
      service_account = local.aws_cloudwatch_observability_service_account
    }
  }

  tags = var.tags
}
