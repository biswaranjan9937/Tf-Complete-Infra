module "vpn_credential_bucket" {
  source = "./modules/s3"
  bucket = var.cred_bucketName
  #attach_policy   = true   ### Attach policy automatically
  #policy        = jsonencode()
  force_destroy = true
  tags          = var.bucketTags
}

module "vpc-flowlog-bucket" {
  source = "./modules/s3"
  bucket = var.vpc_flowlog_bucket
  #attach_policy   = true    ### Attach policy automatically 
  policy        = data.aws_iam_policy_document.flow_log_s3.json
  force_destroy = true
}