# Define an input variable for the AWS region.
variable "region" {
  type        = string
  description = "AWS Region"
}

# Define an input variable for the EC2 instance type.
variable "instance_type" {
  type        = string
  description = "EC2 Instance type"
}

# Define an input variable for custom tags (with a default empty map).
variable "tags" {
  type        = map(string)
  description = "Tags"
  default     = {}
}

