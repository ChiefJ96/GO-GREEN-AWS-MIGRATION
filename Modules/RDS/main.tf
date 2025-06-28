resource "aws_db_subnet_group" "gogreen" {
  name       = "gogreen-db-subnet-group"
  subnet_ids = [var.private_data_subnet_a, var.private_data_subnet_b]

  tags = {
    Name = "GoGreenRDSSubnetGroup"
  }
}

resource "aws_db_instance" "gogreen_db" {
  identifier         = "gogreen-db"
  allocated_storage  = 20
  max_allocated_storage = 100
  storage_type       = "gp3"
  engine             = "mysql"
  engine_version     = "8.0"
  instance_class     = "db.t3.medium"
  username           = var.db_username
  password           = var.db_password
  db_subnet_group_name = aws_db_subnet_group.gogreen.name
  multi_az           = true
  vpc_security_group_ids = [var.rds_sg]
  backup_retention_period = 7
  skip_final_snapshot     = true
  publicly_accessible     = false
  deletion_protection     = false
  storage_encrypted       = true

  tags = {
    Name = "GoGreenDB"
    Environment = "Production"
  }
}
