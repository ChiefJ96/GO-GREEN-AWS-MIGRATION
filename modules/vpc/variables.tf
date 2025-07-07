variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDRs for public subnets"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.16.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDRs for private subnets"
  type        = list(string)
  default     = ["10.32.0.0/24", "10.48.0.0/24"]
}

variable "database_subnet_cidrs" {
  description = "List of CIDRs for database subnets"
  type        = list(string)
  default     = ["10.64.0.0/24", "10.80.0.0/24"]
}

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
  default     = "myapp"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}