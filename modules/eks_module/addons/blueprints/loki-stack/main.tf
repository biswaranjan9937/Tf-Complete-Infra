module "loki-stack" {
  source = "../"

  create = var.enable_loki

  # Disable helm release
  create_release = var.create_kubernetes_resources

  name             = try(var.loki.name, "loki")
  description      = try(var.loki.description, "A Helm chart to install loki")
  namespace        = try(var.loki.namespace, "loki-system")
  create_namespace = try(var.loki.create_namespace, true)
  chart            = try(var.loki.chart, "loki")
  chart_version    = try(var.loki.chart_version, "3.15.0")
  repository       = try(var.loki.repository, "")
  values           = try(var.loki.values, [])

  timeout                    = try(var.loki.timeout, null)
  repository_key_file        = try(var.loki.repository_key_file, null)
  repository_cert_file       = try(var.loki.repository_cert_file, null)
  repository_ca_file         = try(var.loki.repository_ca_file, null)
  repository_username        = try(var.loki.repository_username, null)
  repository_password        = try(var.loki.repository_password, null)
  devel                      = try(var.loki.devel, null)
  verify                     = try(var.loki.verify, null)
  keyring                    = try(var.loki.keyring, null)
  disable_webhooks           = try(var.loki.disable_webhooks, null)
  reuse_values               = try(var.loki.reuse_values, null)
  reset_values               = try(var.loki.reset_values, null)
  force_update               = try(var.loki.force_update, null)
  recreate_pods              = try(var.loki.recreate_pods, null)
  cleanup_on_fail            = try(var.loki.cleanup_on_fail, null)
  max_history                = try(var.loki.max_history, null)
  atomic                     = try(var.loki.atomic, null)
  skip_crds                  = try(var.loki.skip_crds, null)
  render_subchart_notes      = try(var.loki.render_subchart_notes, null)
  disable_openapi_validation = try(var.loki.disable_openapi_validation, null)
  wait                       = try(var.loki.wait, false)
  wait_for_jobs              = try(var.loki.wait_for_jobs, null)
  dependency_update          = try(var.loki.dependency_update, null)
  replace                    = try(var.loki.replace, null)
  lint                       = try(var.loki.lint, null)

  postrender    = try(var.loki.postrender, [])
  set           = try(var.loki.set, [])
  set_sensitive = try(var.loki.set_sensitive, [])

  tags = var.tags
}
