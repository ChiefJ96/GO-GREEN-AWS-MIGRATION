variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}

variable "name_prefix" {
  type    = string
  default = "myapp"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.16.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "database_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0c94855ba95c71c99"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "EC2 Key pair name (optional)"
  type        = string
  default     = null
}

variable "asg_max_size" {
  type    = number
  default = 3
}

variable "asg_min_size" {
  type    = number
  default = 1
}

variable "asg_desired_capacity" {
  type    = number
  default = 1
}

variable "db_name" {
  description = "RDS Database Name"
  type        = string
  default     = "mydb"
}

variable "db_username" {
  description = "RDS Username"
  type        = string
  default     = "myuser"
}

variable "db_password" {
  description = "RDS Password"
  type        = string
  sensitive   = true
}

variable "s3_bucket_name" {
  description = "S3 Bucket name"
  type        = string
}

variable "alerts_email" {
  description = "Email address for SNS alerts"
  type        = string
}
