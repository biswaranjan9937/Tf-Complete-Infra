########################################################################
# EC2-GitHub-Runner
########################################################################
variable "runner_name" {
  type        = string
  description = "Name of GitHub Runner"
}
variable "runner_ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}
variable "runner_egress_rules" {
  description = "List of egress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}
variable "availability_zone" {
  type = string
}
variable "runner_ami_id" {
  type = string
}
variable "runner_instance_type" {
  type = string
}
variable "runner_iam_instance_profile" {
  type = string
}
variable "runner_volume_type" {
  type = string
}
variable "runner_root_volume_size" {
  type = string
}
variable "runner_root_encrypted" {
  type = bool
}
variable "runner_tags" {
  type = map(string)
}
variable "runner_ec2_key_name" {
  type = string
}