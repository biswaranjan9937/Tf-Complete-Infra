terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.98.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.13.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.36.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.19.0"
    }
    cloudinit = {
      source = "hashicorp/cloudinit"
    }
    tls = {
      source = "hashicorp/tls"
    }
    random = {
      source = "hashicorp/random"
    }
    null = {
      source = "hashicorp/null"
    }
  }

  # backend "s3" {
  #   region       = "ap-south-1"
  #   encrypt      = true
  #   bucket       = "incede-terraform-statefiles"
  #   use_lockfile = true
  #   key          = "terraform.tfstate"
  # }
}


