resource "aws_iam_user" "s3_access_user_uat" {
  name = "s3-access-user-uat"
  path = "/system/"

  tags = {
        Name        = aws_iam_user.s3_access_user_uat.name
        Environment = "Uat"
        Implementedby = "Workmates"
        Managedby   = "Workmates"
        Project     = "Innervex-Technologies"
    }
}

resource "aws_iam_access_key" "s3_access_user_uat" {
  user = aws_iam_user.s3_access_user_uat.name
}


data "aws_iam_policy_document" "s3_access_policy_uat" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.uat_s3_bucket.arn,
      "${aws_s3_bucket.uat_s3_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_user_policy" "s3_access_policy_uat" {
  name   = "s3-access-policy-uat"
  user   = aws_iam_user.s3_access_user_uat.name
  policy = data.aws_iam_policy_document.s3_access_policy_uat.json
}

# Create credentials file locally
resource "local_file" "s3_credentials_uat" {
  content = <<-EOT
    AWS_ACCESS_KEY_ID=${aws_iam_access_key.s3_access_user_uat.id}
    AWS_SECRET_ACCESS_KEY=${aws_iam_access_key.s3_access_user_uat.secret}
  EOT
  filename = "${path.module}/iam-user-credentials-uat.txt"

  depends_on = [aws_iam_access_key.s3_access_user_uat]
}

# Upload credentials to S3
resource "null_resource" "upload_credentials_uat" {
  provisioner "local-exec" {
    command = "aws s3 cp ${local_file.s3_credentials_uat.filename} s3://${var.cred_bucketName}/uat-credentials/uat-iam-user-cred.txt  || echo 'Upload failed but continuing...'"
  }

  depends_on = [
    local_file.s3_credentials_uat
  ]
}
