# Set the values for the input variables defined earlier.
region        = "eu-central-1"
instance_type = "t2.micro"

# Define custom tags for the AMI.
#These tags to be applied to Amazon Machine Image created by Packer
tags = {
  "Name"        = "JenkinsImage"
  "Environment" = "Development"
  "OS_Version"  = "Ubuntu 22.04"
  "Release"     = "Latest"
  "Created-by"  = "Packer-200244692886"
}

