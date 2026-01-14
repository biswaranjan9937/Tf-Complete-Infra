terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.98.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.13.0"
    }
    tls = {
      source = "hashicorp/tls"
    }

  }

  backend "s3" {
    region       = "ap-south-2"
    encrypt      = true
    bucket       = "cwm-terraform-statefiles-innervex-technologies"
    use_lockfile = true
    key          = "terraform.tfstate"
  }
}

