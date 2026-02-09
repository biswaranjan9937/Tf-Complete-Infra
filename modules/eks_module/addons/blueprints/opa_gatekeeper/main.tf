module "gatekeeper" {
  source = "../"

  create = var.enable_gatekeeper

  # Disable helm release
  create_release = var.create_kubernetes_resources

  # https://github.com/open-policy-agent/gatekeeper/blob/master/charts/gatekeeper/Chart.yaml
  name             = try(var.gatekeeper.name, "gatekeeper")
  description      = try(var.gatekeeper.description, "A Helm chart to install Gatekeeper")
  namespace        = try(var.gatekeeper.namespace, "gatekeeper-system")
  create_namespace = try(var.gatekeeper.create_namespace, true)
  chart            = try(var.gatekeeper.chart, "gatekeeper")
  chart_version    = try(var.gatekeeper.chart_version, "3.15.0")
  repository       = try(var.gatekeeper.repository, "https://open-policy-agent.github.io/gatekeeper/charts")
  values           = try(var.gatekeeper.values, [])

  timeout                    = try(var.gatekeeper.timeout, null)
  repository_key_file        = try(var.gatekeeper.repository_key_file, null)
  repository_cert_file       = try(var.gatekeeper.repository_cert_file, null)
  repository_ca_file         = try(var.gatekeeper.repository_ca_file, null)
  repository_username        = try(var.gatekeeper.repository_username, null)
  repository_password        = try(var.gatekeeper.repository_password, null)
  devel                      = try(var.gatekeeper.devel, null)
  verify                     = try(var.gatekeeper.verify, null)
  keyring                    = try(var.gatekeeper.keyring, null)
  disable_webhooks           = try(var.gatekeeper.disable_webhooks, null)
  reuse_values               = try(var.gatekeeper.reuse_values, null)
  reset_values               = try(var.gatekeeper.reset_values, null)
  force_update               = try(var.gatekeeper.force_update, null)
  recreate_pods              = try(var.gatekeeper.recreate_pods, null)
  cleanup_on_fail            = try(var.gatekeeper.cleanup_on_fail, null)
  max_history                = try(var.gatekeeper.max_history, null)
  atomic                     = try(var.gatekeeper.atomic, null)
  skip_crds                  = try(var.gatekeeper.skip_crds, null)
  render_subchart_notes      = try(var.gatekeeper.render_subchart_notes, null)
  disable_openapi_validation = try(var.gatekeeper.disable_openapi_validation, null)
  wait                       = try(var.gatekeeper.wait, false)
  wait_for_jobs              = try(var.gatekeeper.wait_for_jobs, null)
  dependency_update          = try(var.gatekeeper.dependency_update, null)
  replace                    = try(var.gatekeeper.replace, null)
  lint                       = try(var.gatekeeper.lint, null)

  postrender    = try(var.gatekeeper.postrender, [])
  set           = try(var.gatekeeper.set, [])
  set_sensitive = try(var.gatekeeper.set_sensitive, [])

  tags = var.tags
}
