resource "aws_db_instance" "main-db" {
  instance_class       = var.instance_class
  engine               = var.engine
  engine_version       = var.engine_version
  username             = var.username
  password             = var.password
  db_name              = var.db_name
  storage_encrypted    = var.encrypt_storage
  allocated_storage    = var.allocated_storage
  apply_immediately    = var.apply_immediately
  skip_final_snapshot  = var.skip_final_snapshot
  multi_az             = false
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = var.vpc_security_group_ids

  tags = {
    Environment = var.env
  }
}


resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "subnet_grp_rds"
  subnet_ids = var.subnet_ids

  tags = {
    Environment = var.env
  }
}
