module "metrics_server" {
  source = "../"

  create = var.enable_metrics_server

  # Disable helm release
  create_release = var.create_kubernetes_resources

  # https://github.com/kubernetes-sigs/metrics-server/blob/master/charts/metrics-server/Chart.yaml
  name             = try(var.metrics_server.name, "metrics-server")
  description      = try(var.metrics_server.description, "A Helm chart to install the Metrics Server")
  namespace        = try(var.metrics_server.namespace, "kube-system")
  create_namespace = try(var.metrics_server.create_namespace, false)
  chart            = try(var.metrics_server.chart, "metrics-server")
  chart_version    = try(var.metrics_server.chart_version, "3.12.0")
  repository       = try(var.metrics_server.repository, "https://kubernetes-sigs.github.io/metrics-server/")
  values           = try(var.metrics_server.values, [])

  timeout                    = try(var.metrics_server.timeout, null)
  repository_key_file        = try(var.metrics_server.repository_key_file, null)
  repository_cert_file       = try(var.metrics_server.repository_cert_file, null)
  repository_ca_file         = try(var.metrics_server.repository_ca_file, null)
  repository_username        = try(var.metrics_server.repository_username, null)
  repository_password        = try(var.metrics_server.repository_password, null)
  devel                      = try(var.metrics_server.devel, null)
  verify                     = try(var.metrics_server.verify, null)
  keyring                    = try(var.metrics_server.keyring, null)
  disable_webhooks           = try(var.metrics_server.disable_webhooks, null)
  reuse_values               = try(var.metrics_server.reuse_values, null)
  reset_values               = try(var.metrics_server.reset_values, null)
  force_update               = try(var.metrics_server.force_update, null)
  recreate_pods              = try(var.metrics_server.recreate_pods, null)
  cleanup_on_fail            = try(var.metrics_server.cleanup_on_fail, null)
  max_history                = try(var.metrics_server.max_history, null)
  atomic                     = try(var.metrics_server.atomic, null)
  skip_crds                  = try(var.metrics_server.skip_crds, null)
  render_subchart_notes      = try(var.metrics_server.render_subchart_notes, null)
  disable_openapi_validation = try(var.metrics_server.disable_openapi_validation, null)
  wait                       = try(var.metrics_server.wait, false)
  wait_for_jobs              = try(var.metrics_server.wait_for_jobs, null)
  dependency_update          = try(var.metrics_server.dependency_update, null)
  replace                    = try(var.metrics_server.replace, null)
  lint                       = try(var.metrics_server.lint, null)

  postrender    = try(var.metrics_server.postrender, [])
  set           = try(var.metrics_server.set, [])
  set_sensitive = try(var.metrics_server.set_sensitive, [])

  tags = var.tags
}