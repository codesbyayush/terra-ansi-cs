locals {
  name_prefix = "${var.name_prefix}-rds"
}

resource "random_string" "db_username" {
  length  = 16
  special = false
  upper   = false
  numeric = false
}

resource "random_password" "db_password" {
  length           = 20
  special          = true
  upper            = true
  lower            = true
  numeric          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# can attach this to resources that need DB access
resource "aws_security_group" "client" {
  name_prefix = "${local.name_prefix}-client-to-server-sg-"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${local.name_prefix}-client-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "server" {
  name_prefix = "${local.name_prefix}-server-to-client-sg-"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${local.name_prefix}-server-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_egress_rule" "client_to_server" {
  security_group_id            = aws_security_group.client.id
  referenced_security_group_id = aws_security_group.server.id
  ip_protocol                  = "tcp"
  from_port                    = var.db_port
  to_port                      = var.db_port
}

resource "aws_vpc_security_group_ingress_rule" "server_from_client" {
  security_group_id            = aws_security_group.server.id
  referenced_security_group_id = aws_security_group.client.id
  ip_protocol                  = "tcp"
  from_port                    = var.db_port
  to_port                      = var.db_port
}

resource "aws_db_subnet_group" "this" {
  name_prefix = "${local.name_prefix}-subnet-grp-"
  subnet_ids  = var.subnet_ids

  tags = {
    Name = "${local.name_prefix}-subnet-grp"
  }
}

resource "aws_db_parameter_group" "this" {
  name_prefix = "${local.name_prefix}-parameter-grp-"
  family      = var.parameter_grp_family

  parameter {
    apply_method = "pending-reboot"
    name         = "max_connections"
    value        = "10"
  }

  tags = {
    Name = "${local.name_prefix}-parameter-grp"
  }
}

resource "aws_db_instance" "this" {
  identifier_prefix      = "${local.name_prefix}-"
  instance_class         = var.instance_class
  engine                 = "postgres"
  engine_version         = var.engine_version
  parameter_group_name   = aws_db_parameter_group.this.name
  username               = random_string.db_username.result
  password               = random_password.db_password.result
  db_name                = var.db_name
  port                   = var.db_port
  storage_encrypted      = var.encrypt_storage
  allocated_storage      = var.allocated_storage
  apply_immediately      = var.apply_immediately
  skip_final_snapshot    = var.skip_final_snapshot
  multi_az               = false
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.server.id]

  tags = {
    Name = local.name_prefix
  }
}
