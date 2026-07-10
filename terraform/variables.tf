variable "aws_region" {
  description = "AWS region in which the infrastructure will be created."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name used for AWS resource names and tags."
  type        = string
  default     = "skillpulse-cicd"
}

variable "instance_type" {
  description = "EC2 instance type used for the application server."
  type        = string
  default     = "t3.small"
}

variable "root_volume_size" {
  description = "Size of the EC2 root EBS volume in GiB."
  type        = number
  default     = 20

  validation {
    condition     = var.root_volume_size >= 10
    error_message = "The root volume must be at least 10 GiB."
  }
}

variable "ssh_allowed_cidr" {
  description = "Single trusted IPv4 CIDR permitted to access SSH."
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_allowed_cidr, 0))
    error_message = "ssh_allowed_cidr must be a valid CIDR such as 203.0.113.10/32."
  }
}

variable "public_key_path" {
  description = "Path to the local SSH public key uploaded to AWS."
  type        = string
  default     = "~/.ssh/skillpulse-ec2.pub"
}
