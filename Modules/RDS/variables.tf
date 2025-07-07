variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private/database subnet IDs for RDS"
  type        = list(string)
}

variable "sg_id" {
  description = "Security group ID to associate with RDS"
  type        = string
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "mydb"
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  default     = "myuser"
}

variable "db_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

variable "allocated_storage" {
  description = "Allocated storage size in GB"
  type        = number
  default     = 20
}

variable "engine_version" {
  description = "Postgres engine version"
  type        = string
  default     = "15.3"
}

variable "instance_class" {
  description = "Instance class type"
  type        = string
  default     = "db.t3.micro"
}

variable "publicly_accessible" {
  description = "Whether RDS instance is publicly accessible"
  type        = bool
  default     = false
}