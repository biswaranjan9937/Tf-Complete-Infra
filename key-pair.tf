##########################################
# Generate SSH key for VPN Server
##########################################
# Generate SSH key
resource "tls_private_key" "vpn_ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create EC2 key pair using public key
resource "aws_key_pair" "vpn_ec2_keypair" {
  key_name   = local.vpn_key_pair
  public_key = tls_private_key.vpn_ec2_key.public_key_openssh
}

# Store private key in S3
resource "aws_s3_object" "vpn_private_key" {
  bucket  = var.cred_bucketName
  key     = "${var.environment}/keypairs/${local.vpn_key_pair}.pem"
  content = tls_private_key.vpn_ec2_key.private_key_pem

  server_side_encryption = "aws:kms"              ### Server Side Encryption with S3-Managed Keys (SSE-S3). You can also use "aws:kms" for Customer-Managed Keys (SSE-KMS) and specify the KMS key ID using the kms_key_id argument.
  kms_key_id             = module.aws_cmk.key_arn ### Optional: Specify the KMS key ID if you want to use a specific KMS key for encryption. If not specified, the default AWS managed key will be used.
  depends_on             = [module.vpn_credential_bucket]
}



###############################################
# Generate SSH key for EKS Application Node Group
###############################################
# Generate TLS private key
resource "tls_private_key" "eks_app_ng_key" { #### This resource will generate a new SSH key pair. The public key will be used to create AWS EC2 key pair and the private key will be stored in S3 bucket.
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS Key Pair
resource "aws_key_pair" "eks_app_ng_keypair" { #### This resource will upload the public key to AWS EC2.
  key_name   = local.eks_app_ng_key_name
  public_key = tls_private_key.eks_app_ng_key.public_key_openssh

  tags = {
    Name        = local.eks_app_ng_key_name
    Environment = var.environment
  }
}

# Upload private key to S3
resource "aws_s3_object" "eks_app_ng_private_key" { #### This resource will upload the private key to S3 bucket.
  bucket                 = var.cred_bucketName      #Replace with your S3 bucket name
  key                    = "${var.environment}/keypairs/${local.eks_app_ng_key_name}.pem"
  content                = tls_private_key.eks_app_ng_key.private_key_pem
  server_side_encryption = "aws:kms"
  kms_key_id             = module.aws_cmk.key_arn ####  If not specified, the default AWS managed key will be used.

  tags = {
    Name        = local.eks_app_ng_key_name
    Environment = var.environment
  }
}


###############################################
# Generate SSH key for EKS Service Node Group
###############################################
# Generate TLS private key
resource "tls_private_key" "eks_svc_ng_key" { #### This resource will generate a new SSH key pair. The public key will be used to create AWS EC2 key pair and the private key will be stored in S3 bucket.
  algorithm = "RSA"
  rsa_bits  = 4096
}
# Create AWS Key Pair
resource "aws_key_pair" "eks_svc_ng_keypair" { #### This resource will upload the public key to AWS EC2.
  key_name   = local.eks_svc_ng_key_name
  public_key = tls_private_key.eks_svc_ng_key.public_key_openssh

  tags = {
    Name        = local.eks_svc_ng_key_name
    Environment = var.environment
  }
}

# Upload private key to S3
resource "aws_s3_object" "eks_svc_ng_private_key" { #### This resource will upload the private key to S3 bucket.
  bucket                 = var.cred_bucketName      #Replace with your S3 bucket name
  key                    = "${var.environment}/keypairs/${local.eks_svc_ng_key_name}.pem"
  content                = tls_private_key.eks_svc_ng_key.private_key_pem
  server_side_encryption = "aws:kms"              # Use "AES256" for S3-managed encryption or "aws:kms" for Ccustomer-managed encryption
  kms_key_id             = module.aws_cmk.key_arn ### Use this if you want to use a specific KMS key for encryption 

  tags = {
    Name        = local.eks_svc_ng_key_name
    Environment = var.environment
  }
}


###############################################
# Generate SSH key for EKS Monitoring Node Group
###############################################
# Generate TLS private key
resource "tls_private_key" "eks_mon_ng_key" { #### This resource will generate a new SSH key pair. The public key will be used to create AWS EC2 key pair and the private key will be stored in S3 bucket.
  algorithm = "RSA"
  rsa_bits  = 4096
}
# Create AWS Key Pair
resource "aws_key_pair" "eks_mon_ng_keypair" { #### This resource will upload the public key to AWS EC2.
  key_name   = local.eks_mon_ng_key_name
  public_key = tls_private_key.eks_mon_ng_key.public_key_openssh

  tags = {
    Name        = local.eks_mon_ng_key_name
    Environment = var.environment
  }
}

# Upload private key to S3
resource "aws_s3_object" "eks_mon_ng_private_key" { #### This resource will upload the private key to S3 bucket.
  bucket                 = var.cred_bucketName      #Replace with your S3 bucket name
  key                    = "${var.environment}/keypairs/${local.eks_mon_ng_key_name}.pem"
  content                = tls_private_key.eks_mon_ng_key.private_key_pem
  server_side_encryption = "aws:kms"              # Use "AES256" for S3-managed encryption or "aws:kms" for Ccustomer-managed encryption
  kms_key_id             = module.aws_cmk.key_arn ### Use this if you want to use a specific KMS key for encryption 

  tags = {
    Name        = local.eks_mon_ng_key_name
    Environment = var.environment
  }
}