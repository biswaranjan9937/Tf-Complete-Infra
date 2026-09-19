terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.2.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.19.0"
    }
  }

  backend "s3" {
    bucket  = "prod-tf-state-bucket" ### This is the S3 bucket name where the terraform state file will be stored. This bucket should be created before running terraform init.
    key     = "dev/statefiles/terraform.tfstate"
    region  = "ap-south-1" ## This should be same as the region where the S3 bucket is created.
    encrypt = true
    # kms_key_id   = "arn:aws:kms:ap-south-1:123456789012:key/xxxxxxxx" ## This is the KMS key ARN which will be used to encrypt the terraform state file. This KMS key should be created before running terraform init.
    use_lockfile = true
  }
}

