provider "aws" {
  region = "ap-south-1"
  default_tags {
    tags = {
      "Implementedby" = "Workmates",
      "Managedby"     = "Workmates",
      "Environment"   = "Prod",
      "Project"       = "POC"
    }
  }
}