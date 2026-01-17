##########################################
# Generate SSH key for UAT
##########################################
# Generate SSH key
resource "tls_private_key" "uat_ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create EC2 key pair using public key
resource "aws_key_pair" "uat_ec2_keypair" {
  key_name   = var.uat_ec2_key_name
  public_key = tls_private_key.uat_ec2_key.public_key_openssh
}

# Store private key in S3
resource "aws_s3_object" "uat_private_key" {
  bucket  = "cwm-terraform-statefiles-innervex-technologies"  # Use your existing credentials bucket
  key     = "key-pairs/${var.uat_ec2_key_name}.pem"
  content = tls_private_key.uat_ec2_key.private_key_pem

  server_side_encryption = "AES256"
}


##########################################
# Generate SSH key for PROD
##########################################
# Generate SSH key
resource "tls_private_key" "prod_ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create EC2 key pair using public key
resource "aws_key_pair" "prod_ec2_keypair" {
  key_name   = var.prod_ec2_key_name
  public_key = tls_private_key.prod_ec2_key.public_key_openssh
}

# Store private key in S3
resource "aws_s3_object" "prod_private_key" {
  bucket  = "cwm-terraform-statefiles-innervex-technologies"  # Use your existing credentials bucket
  key     = "key-pairs/${var.prod_ec2_key_name}.pem"
  content = tls_private_key.prod_ec2_key.private_key_pem

  server_side_encryption = "AES256"
}


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
  bucket  = "cwm-terraform-statefiles-innervex-technologies"  # Use your existing credentials bucket
  key     = "key-pairs/${var.ec2_pritunl_key_name}.pem"
  content = tls_private_key.vpn_ec2_key.private_key_pem

  server_side_encryption = "AES256"
}