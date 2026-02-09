#####################################################
# AWS Providers
#####################################################

provider "aws" {
  region = var.region_backend
  default_tags {
    tags = {
      "Implementedby" = "Workmates",
      "Managedby"     = "Workmates",
      "Environment"   = "Prod",
      "Project"       = "${var.Project_Name}"
    }
  }
}
# For multiple regions, uncomment and modify as needed
# provider "aws" {
#   region = "ap-south-2"
#   alias  = "hyderabad"
# }

#####################################################
# EKS Suppporting Providers
#####################################################

provider "kubernetes" {
  host                   = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token

}

provider "kubectl" {
  host                   = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
  #token                  = data.aws_eks_cluster_auth.cluster.token
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks_cluster.cluster_name]
    command     = "aws"
  }
  #load_config_file = false
}

provider "helm" {
  kubernetes {
    host                   = module.eks_cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks_cluster.cluster_name]
      command     = "aws"
    }
  }
}

