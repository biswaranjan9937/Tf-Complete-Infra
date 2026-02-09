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
# Velero
################################################################################

locals {
  velero_name                    = "velero"
  velero_service_account         = try(var.velero.service_account_name, "${local.velero_name}-server")
  velero_backup_s3_bucket        = try(split(":", var.velero.s3_backup_location), [])
  velero_backup_s3_bucket_arn    = try(split("/", var.velero.s3_backup_location)[0], var.velero.s3_backup_location, "")
  velero_backup_s3_bucket_name   = try(split("/", local.velero_backup_s3_bucket[5])[0], local.velero_backup_s3_bucket[5], "")
  velero_backup_s3_bucket_prefix = try(split("/", var.velero.s3_backup_location)[1], "")
  velero_namespace               = try(var.velero.namespace, "velero")
  kmsKeyId                       = try(var.velero.kmsKeyId, "")
}

data "aws_iam_policy_document" "velero" {
  count = var.enable_velero ? 1 : 0

  source_policy_documents   = lookup(var.velero, "source_policy_documents", [])
  override_policy_documents = lookup(var.velero, "override_policy_documents", [])

  statement {
    actions = [
      "ec2:CreateSnapshot",
      "ec2:CreateSnapshots",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteSnapshot"
    ]
    resources = [
      "arn:${local.partition}:ec2:${local.region}:${local.account_id}:instance/*",
      "arn:${local.partition}:ec2:${local.region}::snapshot/*",
      "arn:${local.partition}:ec2:${local.region}:${local.account_id}:volume/*"
    ]
  }

  statement {
    actions = [
      "ec2:DescribeSnapshots",
      "ec2:DescribeVolumes"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
    ]
    resources = ["${var.velero.s3_backup_location}/*"]
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [local.velero_backup_s3_bucket_arn]
  }
}

module "velero" {
  source = "../"
  create = var.enable_velero

  # Disable helm release
  create_release = var.create_kubernetes_resources

  name             = try(var.velero.name, "velero")
  description      = try(var.velero.description, "A Helm chart to install the Velero")
  namespace        = local.velero_namespace
  create_namespace = try(var.velero.create_namespace, true)
  chart            = try(var.velero.chart, "velero")
  chart_version    = try(var.velero.chart_version, "8.3.0")
  repository       = try(var.velero.repository, "https://vmware-tanzu.github.io/helm-charts/")
  values           = try(var.velero.values, [])

  timeout                    = try(var.velero.timeout, null)
  repository_key_file        = try(var.velero.repository_key_file, null)
  repository_cert_file       = try(var.velero.repository_cert_file, null)
  repository_ca_file         = try(var.velero.repository_ca_file, null)
  repository_username        = try(var.velero.repository_username, null)
  repository_password        = try(var.velero.repository_password, null)
  devel                      = try(var.velero.devel, null)
  verify                     = try(var.velero.verify, null)
  keyring                    = try(var.velero.keyring, null)
  disable_webhooks           = try(var.velero.disable_webhooks, null)
  reuse_values               = try(var.velero.reuse_values, null)
  reset_values               = try(var.velero.reset_values, null)
  force_update               = try(var.velero.force_update, null)
  recreate_pods              = try(var.velero.recreate_pods, null)
  cleanup_on_fail            = try(var.velero.cleanup_on_fail, null)
  max_history                = try(var.velero.max_history, null)
  atomic                     = try(var.velero.atomic, null)
  skip_crds                  = try(var.velero.skip_crds, null)
  render_subchart_notes      = try(var.velero.render_subchart_notes, null)
  disable_openapi_validation = try(var.velero.disable_openapi_validation, null)
  wait                       = try(var.velero.wait, false)
  wait_for_jobs              = try(var.velero.wait_for_jobs, null)
  dependency_update          = try(var.velero.dependency_update, null)
  replace                    = try(var.velero.replace, null)
  lint                       = try(var.velero.lint, null)

  postrender = try(var.velero.postrender, [])
  set = concat([
    {
      name  = "initContainers"
      value = <<-EOT
        - name: velero-plugin-for-aws
          image: velero/velero-plugin-for-aws:v1.11.0
          imagePullPolicy: IfNotPresent
          volumeMounts:
            - mountPath: /target
              name: plugins
      EOT
    },
    {
      name  = "serviceAccount.server.name"
      value = local.velero_service_account
    },
    {
      name  = "configuration.backupStorageLocation[0].name"
      value = "default"
    },
    {
      name  = "configuration.backupStorageLocation[0].provider"
      value = "aws"
    },
    # {
    #   name  = "configuration.backupStorageLocation[0].prefix"
    #   value = local.velero_backup_s3_bucket_prefix
    # },
    {
      name  = "configuration.backupStorageLocation[0].bucket"
      value = local.velero_backup_s3_bucket_name
    },
    {
      name  = "configuration.backupStorageLocation[0].config.region"
      value = local.region
    },
    # {
    #   name  = "configuration.backupStorageLocation[0].config.kmsKeyId"
    #   value = local.kmsKeyId
    # },
    {
      name  = "configuration.volumeSnapshotLocation[0].name"
      value = "default"
    },
    {
      name  = "configuration.volumeSnapshotLocation[0].provider"
      value = "aws"
    },
    {
      name  = "configuration.volumeSnapshotLocation[0].config.region"
      value = local.region
    },
    {
      name  = "credentials.useSecret"
      value = false
    }],
    try(var.velero.set, [])
  )
  set_sensitive = try(var.velero.set_sensitive, [])

  # IAM role for service account (IRSA)
  set_irsa_names                = ["serviceAccount.server.annotations.eks\\.amazonaws\\.com/role-arn"]
  create_role                   = try(var.velero.create_role, true)
  role_name                     = try(var.velero.role_name, "velero")
  role_name_use_prefix          = try(var.velero.role_name_use_prefix, false)
  role_path                     = try(var.velero.role_path, "/")
  role_permissions_boundary_arn = lookup(var.velero, "role_permissions_boundary_arn", null)
  role_description              = try(var.velero.role_description, "IRSA for Velero")
  role_policies                 = lookup(var.velero, "role_policies", {})

  source_policy_documents = data.aws_iam_policy_document.velero[*].json
  policy_statements       = lookup(var.velero, "policy_statements", [])
  policy_name             = try(var.velero.policy_name, "velero")
  policy_name_use_prefix  = try(var.velero.policy_name_use_prefix, false)
  policy_path             = try(var.velero.policy_path, null)
  policy_description      = try(var.velero.policy_description, "IAM Policy for Velero")

  oidc_providers = {
    controller = {
      provider_arn = local.oidc_provider_arn
      # namespace is inherited from chart
      service_account = local.velero_service_account
    }
  }

  tags = var.tags
}
