##########################################
# Generate SSH key for GitHub Runner EC2 Server
##########################################
# Generate SSH key
resource "tls_private_key" "runner_ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create EC2 key pair using public key
resource "aws_key_pair" "runner_ec2_keypair" {
  key_name   = var.runner_ec2_key_name
  public_key = tls_private_key.runner_ec2_key.public_key_openssh
}

# Store private key in S3
resource "aws_s3_object" "runner_private_key" {
  bucket  = "cwm-terraform-statefiles-innervex-technologies" # Use your existing credentials bucket
  key     = "key-pairs/${var.runner_ec2_key_name}.pem"
  content = tls_private_key.runner_ec2_key.private_key_pem

  server_side_encryption = "AES256"
}