variable "bucket_name" {
  description = "go-green-s3-bucket-jura"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "ec2_role_arn" {
  description = "ARN of the EC2 role for S3 bucket policy"
  type        = string
}