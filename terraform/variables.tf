variable "aws_profile" {
  description = "AWS CLI profile name"
  type        = string
  default     = "tc3"
}

variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "ssh_ingress_cidr" {
  description = "Your public IP (CIDR) allowed to SSH (port 22). Keep /32."
  type        = string
  default     = "208.104.74.153/32"
  validation {
    condition     = can(cidrnetmask(var.ssh_ingress_cidr))
    error_message = "Must be a valid CIDR like 203.0.113.10/32."
  }
}

variable "ssh_public_key" {
  description = "Public key used to SSH into the EC2 instance"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGP3RSNS4kunmA9kDHAoIDzBkaNIcLJfIUiqP5qvV78G DesG01211517"
}
