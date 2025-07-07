terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}


module "vpc" {
  source                = "./modules/vpc"
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  name_prefix           = var.name_prefix
  region                = var.region
}
module "security_groups" {
  source      = "./modules/security_groups"
  vpc_id      = module.vpc.vpc_id
  name_prefix = var.name_prefix
}
module "iam" {
  source      = "./modules/iam"
  name_prefix = var.name_prefix
}
module "s3" {
  source        = "./modules/s3"
  bucket_name   = var.s3_bucket_name
  name_prefix   = var.name_prefix
  ec2_role_arn  = module.iam.ec2_role_arn
}
module "alb_web" {
  source           = "./modules/alb"
  name_prefix      = var.name_prefix
  vpc_id           = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.security_groups.web_sg_id
}

# For App tier ALB (optional; based on diagram)
module "alb_app" {
  source           = "./modules/alb"
  name_prefix      = "${var.name_prefix}-app"
  vpc_id           = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.security_groups.app_sg_id
}
module "asg_web" {
  source                   = "./modules/asg"
  name_prefix              = var.name_prefix
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.public_subnet_ids
  security_group_id        = module.security_groups.web_sg_id
  target_group_arn         = module.alb_web.target_group_arn
  iam_instance_profile_name = module.iam.ec2_instance_profile_name
  ami_id                   = var.ami_id
  instance_type            = var.instance_type
  key_name                 = var.key_name
  max_size                 = var.asg_max_size
  min_size                 = var.asg_min_size
  desired_capacity         = var.asg_desired_capacity
  assign_public_ip         = true  # Web tier needs public IP for internet access
}

module "asg_app" {
  source                   = "./modules/asg"
  name_prefix              = "${var.name_prefix}-app"
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnet_ids
  security_group_id        = module.security_groups.app_sg_id
  target_group_arn         = module.alb_app.target_group_arn
  iam_instance_profile_name = module.iam.ec2_instance_profile_name
  ami_id                   = var.ami_id
  instance_type            = var.instance_type
  key_name                 = var.key_name
  max_size                 = var.asg_max_size
  min_size                 = var.asg_min_size
  desired_capacity         = var.asg_desired_capacity
  assign_public_ip         = false  # App tier in private subnet, no public IP
}
  module "rds" {
  source             = "./modules/rds"
  name_prefix        = var.name_prefix
  private_subnet_ids = module.vpc.database_subnet_ids
  sg_id              = module.security_groups.db_sg_id
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  allocated_storage  = 20
  engine_version     = "15.7"
  instance_class     = "db.t3.micro"
  publicly_accessible = false
}
module "monitoring" {
  source      = "./modules/monitoring"
  name_prefix = var.name_prefix
  sns_email   = var.alerts_email
  asg_name    = module.asg_web.asg_name # Adjust accordingly if output is unavailable, see note below
  db_identifier = module.rds.primary_db_identifier
}