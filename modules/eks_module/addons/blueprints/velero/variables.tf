variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.24`)"
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN of the cluster OIDC Provider"
  type        = string
}
variable "enable_velero" {
  description = "Enable metrics server add-on"
  type        = bool
  default     = false
}

variable "velero" {
  description = "Metrics Server add-on configurations"
  type        = any
  default     = {}
}
variable "create_kubernetes_resources" {
  description = "Create Kubernetes resource with Helm or Kubernetes provider"
  type        = bool
  default     = true
}