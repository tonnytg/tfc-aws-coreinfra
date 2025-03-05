provider "aws" {
  region = "us-east-1"
}

resource "aws_lightsail_instance" "main" {
  name              = "k8s-debian-instance"
  availability_zone = "us-east-1a"
  blueprint_id      = "debian_12"  # Confirme se este ID está correto via AWS CLI
  bundle_id         = "small_3_0"  # Confirme as specs: 2 vCPUs, 2GB RAM, 60GB SSD, 3TB
  key_pair_name     = "aws_key_pair_virginia"

  user_data = file("${path.module}/script.sh")

  tags = {
    Environment = "development"
  }
}

