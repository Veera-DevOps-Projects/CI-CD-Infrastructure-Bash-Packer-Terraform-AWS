# Define a local variable to generate a timestamp.
#It creates unique identifier
locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "postgres-sonardb-server-${local.timestamp}"
  instance_type = var.instance_type
  region        = var.region
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20230208"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners = ["099720109477"]
  }

  ssh_username = "ubuntu"
  tags         = var.tags
  aws_polling {
    delay_seconds = 30
    max_attempts  = 300
  }

}

# Define a source block for creating an AMI using the Amazon EBS builder.
#It includes settings for the resulting AMI, the source image to use, and more.

build {
  name        = "postgres-sonardb-server"
  description = <<EOF
  This build creates aws linux images for postgres server
  EOF
  sources     = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    script = "./scripts/postgres.sh"
  }
}