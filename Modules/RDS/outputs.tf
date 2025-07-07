output "endpoint" {
  description = "Primary DB endpoint address"
  value       = aws_db_instance.primary.endpoint
}

output "read_replica_endpoint" {
  description = "Read Replica endpoint address"
  value       = aws_db_instance.read_replica.endpoint
}
output "primary_db_identifier" {
  value = aws_db_instance.primary.id
}