#############################
# Data sources (default VPC)
#############################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

#############################
# Security Group
#############################
resource "aws_security_group" "web_sg" {
  name        = "tc3-web-sg"
  description = "Allow SSH from my IP and HTTP from anywhere"
  vpc_id      = data.aws_vpc.default.id

  # SSH (your IP only)
  ingress {
    description = "SSH from my public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ingress_cidr]
  }

  # HTTP (open)
  ingress {
    description = "HTTP for web traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress (all)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "tc3-web-sg"
    Project     = "tech-challenge-3"
    Environment = "dev"
  }
}

#############################
# Key pair (uses your public key)
#############################
resource "aws_key_pair" "tc3" {
  key_name   = "tc3-key"
  public_key = var.ssh_public_key
}

#############################
# IAM role for EC2 (SSM access)
#############################
resource "aws_iam_role" "ec2_role" {
  name = "tc3-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Action    = "sts:AssumeRole",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
  tags = {
    Project = "tech-challenge-3"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "tc3-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

#############################
# S3 bucket (unique suffix)
#############################
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  lower   = true
  numeric = true
  special = false
}

resource "aws_s3_bucket" "artifact_bucket" {
  bucket = "tc3-desmon-${random_string.suffix.id}"
  tags = {
    Name        = "tc3-desmon-${random_string.suffix.id}"
    Project     = "tech-challenge-3"
    Environment = "dev"
  }
}

#############################
# AMI for Amazon Linux 2 (x86_64)
#############################
data "aws_ami" "amzn2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#############################
# EC2 instance (free tier type)
#############################
resource "aws_instance" "web" {
  ami                    = data.aws_ami.amzn2.id
  instance_type          = "t2.micro" # free-tier eligible in us-east-1
  subnet_id              = element(data.aws_subnets.default.ids, 0)
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  key_name                    = aws_key_pair.tc3.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true

  tags = {
    Name        = "tc3-web"
    Project     = "tech-challenge-3"
    Environment = "dev"
  }
}
