
module "ecr_repositories" {
  source = "./modules/ecr_module"

  repository_names        = var.repository_names
  create                  = true
  create_repository       = true
  create_lifecycle_policy = true
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep lastest 10 images",
        selection = {
          tagStatus   = "any",
          countType   = "imageCountMoreThan",
          countNumber = 10
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
  repository_type                 = var.repository_type
  repository_image_tag_mutability = var.tag_mutability ### It means same tag image can be pushed multiple times.
  repository_encryption_type      = "KMS"
  repository_kms_key              = local.ecr_kms_key_arn
  repository_force_delete         = var.repository_force_delete ### Terraform will delete the ECR repository even if it still contains images.
  repository_image_scan_on_push   = true
  tags                            = var.ecr_tags
}

