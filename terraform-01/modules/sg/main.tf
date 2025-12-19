resource "aws_security_group" "enable_http" {
  name   = "SG - HTTP"
  vpc_id = var.vpc_id

  tags = {
    Environment = var.env
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_enable_http" {
  for_each          = var.ingress_ips
  security_group_id = aws_security_group.enable_http.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = each.key
}

resource "aws_security_group" "enable_outbound" {
  name   = "SG - ALL OUTBOUND"
  vpc_id = var.vpc_id

  tags = {
    Environment = var.env
  }
}

resource "aws_vpc_security_group_egress_rule" "egress_enable_outbound" {
  security_group_id = aws_security_group.enable_outbound.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "enable_dev_access" {
  name = "SG - WinRM, SSH, RDP"
  vpc_id = var.vpc_id

  tags = {
    Environment = var.env
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_enable_winrm_http" {
  security_group_id = aws_security_group.enable_dev_access.id
  ip_protocol = "tcp"
  from_port = 5985
  to_port = 5985
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "ingress_enable_winrm_https" {
  security_group_id = aws_security_group.enable_dev_access.id
  ip_protocol = "tcp"
  from_port = 5986
  to_port = 5986
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "ingress_enable_ssh" {
  for_each          = var.ingress_ips
  security_group_id = aws_security_group.enable_dev_access.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = each.key
}

resource "aws_vpc_security_group_ingress_rule" "ingress_enable_rdp" {
  for_each          = var.ingress_ips
  security_group_id = aws_security_group.enable_dev_access.id
  from_port         = 3389
  to_port           = 3389
  ip_protocol       = "tcp"
  cidr_ipv4         = each.key
}

# Stacked security groups (Client - Server)
resource "aws_security_group" "rds_client" {
  name   = "SG - RDS client"
  vpc_id = var.vpc_id

  tags = {
    Environment = var.env
  }
}

resource "aws_security_group" "rds_server" {
  name   = "SG - RDS server"
  vpc_id = var.vpc_id

  tags = {
    Environment = var.env
  }
}

resource "aws_vpc_security_group_egress_rule" "egress_rds_client" {
  security_group_id            = aws_security_group.rds_client.id
  referenced_security_group_id = aws_security_group.rds_server.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rds_server" {
  security_group_id            = aws_security_group.rds_server.id
  referenced_security_group_id = aws_security_group.rds_client.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}
