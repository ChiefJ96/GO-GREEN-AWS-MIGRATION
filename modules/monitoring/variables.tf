variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "sns_email" {
  description = "jahmadjonov@gmail.com"
  type        = string
}

variable "asg_name" {
  description = "Name of the Auto Scaling Group to monitor"
  type        = string
}

variable "db_identifier" {
  description = "RDS DB Instance identifier"
  type        = string
}