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
  key_name   = var.ec2_pritunl_key_name
  public_key = tls_private_key.vpn_ec2_key.public_key_openssh
}

# Store private key in S3
resource "aws_s3_object" "vpn_private_key" {
  bucket  = var.cred_bucketName
  key     = "key-pairs/${var.ec2_pritunl_key_name}.pem"
  content = tls_private_key.vpn_ec2_key.private_key_pem

  server_side_encryption = "AES256"

  depends_on = [module.vpn_credential_bucket]
}


# Generate TLS private key
resource "tls_private_key" "eks_node_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS Key Pair
resource "aws_key_pair" "eks_node_keypair" {
  key_name   = "eks-uat-keypair" # Change name as needed
  public_key = tls_private_key.eks_node_key.public_key_openssh

  tags = {
    Name        = "AFPL-EKS-UAT-KeyPair"
    Environment = "UAT"
  }
}

# Upload private key to S3
resource "aws_s3_object" "private_key" {
  bucket                 = var.cred_bucketName #Replace with your S3 bucket name
  key                    = "keypairs/eks-uat-keypair.pem"
  content                = tls_private_key.eks_node_key.private_key_pem
  server_side_encryption = "AES256"
  # kms_key_id            = "your-kms-key-id"

  tags = {
    Name        = "AFPL-EKS-UAT-Private-Key"
    Environment = "UAT"
  }
}