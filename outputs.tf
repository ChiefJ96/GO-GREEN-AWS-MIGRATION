output "vpc_id" {
  value = module.vpc.vpc_id
}
output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}
output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}
output "database_subnet_ids" {
  value = module.vpc.database_subnet_ids
}
output "alb_web_dns" {
  value = module.alb_web.alb_dns_name
}
output "alb_app_dns" {
  value = module.alb_app.alb_dns_name
}
output "s3_bucket_name" {
  value = var.s3_bucket_name
}
output "rds_endpoint" {
  value = module.rds.endpoint
}