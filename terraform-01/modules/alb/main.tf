locals {
  name_prefix = "${var.name_prefix}-alb"

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

  target_group_attachments = flatten([
    for tg_key, tg_value in var.target_groups : [
      for target_id in tg_value.target_ids : {
        target_group_key = tg_key
        target_id        = target_id
      }
    ]
  ])
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
    for rule in local.ingress_rules_flat :
    "${rule.from_port}-${rule.to_port}-${rule.protocol}-${rule.cidr}" => rule
  }

  security_group_id = aws_security_group.this.id
  ip_protocol       = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  cidr_ipv4         = each.value.cidr
  description       = each.value.description
}

resource "aws_lb" "this" {
  name               = local.name_prefix
  load_balancer_type = "application"
  internal           = var.internal
  subnets            = tolist(var.subnets)
  security_groups    = [aws_security_group.this.id]

  tags = {
    Name = local.name_prefix
  }
}

resource "aws_lb_target_group" "this" {
  for_each         = var.target_groups
  name             = "${local.name_prefix}-tg-${each.key}"
  port             = each.value.port
  protocol         = each.value.protocol
  protocol_version = each.value.protocol_version
  vpc_id           = var.vpc_id

  tags = {
    Name = "${local.name_prefix}-tg-${each.key}"
  }
}

resource "aws_lb_target_group_attachment" "this" {
  count = length(local.target_group_attachments)

  target_group_arn = aws_lb_target_group.this[local.target_group_attachments[count.index].target_group_key].arn
  target_id        = local.target_group_attachments[count.index].target_id
}

resource "aws_lb_listener" "this" {
  for_each = var.listeners

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = each.value.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }

  tags = {
    Name = "${local.name_prefix}-listener-${each.key}"
  }
}
