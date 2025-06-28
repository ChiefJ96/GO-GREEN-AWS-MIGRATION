variable "vpc_id" {}
variable "public_subnet_a" {}
variable "public_subnet_b" {}
variable "alb_sg" {}
variable "ec2_sg" {
  description = "EC2 security group to attach to the ALB"
  type        = string
}

variable "target_group_name" {
  description = "Name for the target group"
  type        = string
}

variable "health_check_path" {
  description = "Health check path for the target group"
  type        = string
  default     = "/"
}

