resource "aws_iam_user" "s3_access_user" {
  name = "s3-access-user"
  path = "/system/"

  tags = {
        Name        = self.name
        Environment = "Prod"
        Implementedby = "Workmates"
        Managedby   = "Workmates"
        Project     = "Innervex-Technologies"
    }
}

resource "aws_iam_access_key" "s3_access_user" {
  user = aws_iam_user.s3_access_user.name
}

data "aws_iam_policy_document" "s3_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [
      "aws_s3_bucket.uat_s3_bucket.arn",
      "aws_s3_bucket.uat_s3_bucket.arn/*",
      "aws_s3_bucket.prod_s3_bucket.arn",
      "aws_s3_bucket.prod_s3_bucket.arn/*"
    ]
  }
}

resource "aws_iam_user_policy" "s3_access_policy" {
  name   = "s3-access-policy"
  user   = aws_iam_user.s3_access_user.name
  policy = data.aws_iam_policy_document.s3_access.json
}
