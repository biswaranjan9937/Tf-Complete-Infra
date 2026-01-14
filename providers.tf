#####################################################
# AWS Providers
#####################################################
# Here are the provider declaration
provider "aws" {
  region = var.region_backend
  default_tags {
    tags = {
      "Implementedby" = "Workmates",
      "Managedby"     = "Workmates",
      "Environment"   = "Prod",
      "Project"       = "Innervex-Technologies"
    }
  }
}
provider "aws" {
  region = "ap-south-2"
  alias  = "hyderabad"
}
#####################################################
