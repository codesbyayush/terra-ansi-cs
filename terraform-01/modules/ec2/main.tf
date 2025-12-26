data "aws_ami" "this" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2025-English-Full-Base-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

locals {
  name_prefix = "${var.name_prefix}-ec2"

  ssh_rules = var.enable_ssh ? [
    for cidr in var.dev_access_cidrs : {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr        = cidr
      description = "SSH"
    }
  ] : []

  rdp_rules = var.enable_rdp ? [
    for cidr in var.dev_access_cidrs : {
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      cidr        = cidr
      description = "RDP"
    }
  ] : []

  ingress_rules_flat = flatten([
    for rule in var.ingress_rules : [
      for cidr in rule.cidr_blocks : {
        from_port   = rule.from_port
        to_port     = rule.to_port
        protocol    = rule.protocol
        cidr        = cidr
        description = rule.description
      }
    ]
  ])

  egress_rules_flat = flatten([
    for rule in var.egress_rules : [
      for cidr in rule.cidr_blocks : {
        from_port   = rule.from_port
        to_port     = rule.to_port
        protocol    = rule.protocol
        cidr        = cidr
        description = rule.description
      }
    ]
  ])

  all_ingress_rules = concat(
    local.ssh_rules,
    local.rdp_rules,
    local.ingress_rules_flat
  )

  is_burstable = startswith(var.instance_type, "t")
}

resource "aws_security_group" "this" {
  name_prefix = "${local.name_prefix}-"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${local.name_prefix}-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Did this as change in order with indexed based keys was causing 
# recreation of resource even though it didn't change so this rule 
# based key is same and prevents that
resource "aws_vpc_security_group_egress_rule" "egress" {
  for_each = {
    for rule in local.egress_rules_flat :
    "${rule.from_port}-${rule.to_port}-${rule.protocol}-${rule.cidr}" => rule
  }

  security_group_id = aws_security_group.this.id
  ip_protocol       = each.value.protocol
  from_port         = each.value.protocol == "-1" ? null : each.value.from_port
  to_port           = each.value.protocol == "-1" ? null : each.value.to_port
  cidr_ipv4         = each.value.cidr
  description       = each.value.description
}

resource "aws_vpc_security_group_ingress_rule" "ingress" {
  for_each = {
    for rule in local.all_ingress_rules :
    "${rule.from_port}-${rule.to_port}-${rule.protocol}-${rule.cidr}" => rule
  }

  security_group_id = aws_security_group.this.id
  ip_protocol       = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  cidr_ipv4         = each.value.cidr
  description       = each.value.description
}

resource "aws_instance" "this" {
  count                  = length(var.subnets)
  ami                    = data.aws_ami.this.id
  instance_type          = var.instance_type
  subnet_id              = var.subnets[count.index]
  vpc_security_group_ids = concat([aws_security_group.this.id], var.additional_sg_ids)
  key_name               = var.key_name
  user_data              = var.user_data

  dynamic "credit_specification" {
    for_each = [for type in [var.cpu_credits_type] : type if local.is_burstable]
    content {
      cpu_credits = var.cpu_credits_type
    }
  }

  tags = merge(
    var.instance_tags,
    {
      Name = "${local.name_prefix}-${count.index + 1}"
    }
  )
}
