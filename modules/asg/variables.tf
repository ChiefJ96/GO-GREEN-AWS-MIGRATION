variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the instances"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where ASG instances will run"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for EC2 instances"
  type        = string
}

variable "target_group_arn" {
  description = "ALB Target Group ARN to register instances"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name to associate with EC2 instances"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH access (optional)"
  type        = string
  default     = null
}

variable "min_size" {
  description = "Minimum size of the ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum size of the ASG"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of instances"
  type        = number
  default     = 2
}

variable "assign_public_ip" {
  description = "Whether to assign public IP to instances"
  type        = bool
  default     = false
}