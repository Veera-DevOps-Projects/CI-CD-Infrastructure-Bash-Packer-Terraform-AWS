# Define a local variable to generate a timestamp.
#It creates unique identifier
locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}


# Define a source block for creating an AMI using the Amazon EBS builder.
#It includes settings for the resulting AMI, the source image to use, and more.

# source
source "amazon-ebs" "aws_linux" {
  # Specify the name for the resulting AMI.
  ami_name      = "nexus-server-${local.timestamp}"

  # EC2 instance type that uses Packer for creating AMI 
  instance_type = var.instance_type
  
  # Use the AWS region specified in variables.
  region        = var.region

  #vpc_id = "vpc-0858fc82b15175a7f"

  # Filter the source AMI by various criteria.
  # Packer uses following as a base. 
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-kernel-5.10-hvm-2.0.20221210.1-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners = ["137112412989"]
  }

 # SSH username that Packer will use to communicate with the EC2 instance
  ssh_username = "ec2-user"

  # Apply custom tags to the resulting AMI.
  tags         = var.tags

  # how frequently Packer checks the status of the image creation process
  aws_polling {
    delay_seconds = 30
    max_attempts  = 300
  }

}

# Define a build block for this Packer build.
#This section defines how the Packer build process is configured 
#including the name and description of the build, the source, and provisioners (in your case, a shell script).

build {
  name        = "nexus-server"
  description = <<EOF
  This build creates aws linux images for nexus server
  EOF

# Specify the source for this build, which is the previously defined Amazon EBS source.
  sources     = ["source.amazon-ebs.aws_linux"]

# Define a shell provisioner to run a script.
  provisioner "shell" {
    script = "./scripts/nexus.sh"
  }
}