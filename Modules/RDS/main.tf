resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.name_prefix}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.name_prefix}-rds-subnet-group"
  }
}

resource "aws_db_instance" "primary" {
  identifier             = "${var.name_prefix}-primary-db"
  allocated_storage      = var.allocated_storage
  engine                 = "postgres"
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.postgres15"
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [var.sg_id]
  publicly_accessible    = var.publicly_accessible
  skip_final_snapshot    = true
  backup_retention_period = 7

  tags = {
    Name = "${var.name_prefix}-primary-db"
  }
}

resource "aws_db_instance" "read_replica" {
  identifier              = "${var.name_prefix}-read-replica"
  instance_class          = var.instance_class
  engine                  = "postgres"
  engine_version          = var.engine_version
  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [var.sg_id]
  replicate_source_db     = aws_db_instance.primary.arn
  skip_final_snapshot     = true

  tags = {
    Name = "${var.name_prefix}-read-replica"
  }
}