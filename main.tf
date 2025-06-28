terraform {
  backend "s3" {
    bucket         = "terraform.tfstate-go-green"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-go-green"
    encrypt        = true
  }
}


provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./modules/vpc"
}
module "iam" {
  source = "./modules/iam"
}
module "s3" {
  source = "./modules/s3"
}
module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_a   = module.vpc.public_subnet_a
  public_subnet_b   = module.vpc.public_subnet_b
  alb_sg            = module.vpc.alb_sg
  ec2_sg            = module.vpc.ec2_sg
  target_group_name = "gogreen-web-tg"
}
module "ec2" {
  source           = "./modules/ec2"
  ami_id           = "ami-0abcdef1234567890"
  instance_type    = "t3.medium"
  key_name         = "gogreen-key"
  instance_profile = "EC2toS3IAMRole"
  private_subnet_a = module.vpc.private_app_subnet_a
  private_subnet_b = module.vpc.private_app_subnet_b
  target_group_arn = module.alb.web_tg_arn
  ec2_sg           = module.vpc.ec2_sg
}

module "rds" {
  source = "./modules/rds"

  private_data_subnet_a = module.vpc.private_data_subnet_a
  private_data_subnet_b = module.vpc.private_data_subnet_b
  rds_sg                = module.vpc.rds_sg
  db_username           = "admin"
  db_password           = "MySecurePassword123!"
}

module "monitoring" {
  source   = "./modules/monitoring"
  asg_name = "gogreen-asg"
}
module "codepipeline" {
  source        = "./modules/codepipeline"
  github_token  = var.github_token
  s3_bucket     = module.s3.bucket_name
  github_owner  = var.github_owner
  github_repo   = var.github_repo
  github_branch = var.github_branch
}

variable "github_branch" {
  description = "The GitHub branch to use for CodePipeline"
  type        = string
}

variable "github_repo" {
  description = "The GitHub repository name to use for CodePipeline"
  type        = string
}

variable "github_owner" {
  description = "The GitHub owner (user or organization) to use for CodePipeline"
  type        = string
}