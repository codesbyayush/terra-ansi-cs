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
  internal           = false
  subnets            = tolist(var.subnets)
  security_groups    = [aws_security_group.this.id]

  tags = {
    Name = local.name_prefix
  }
}

resource "aws_lb_target_group" "this" {
  name             = "${local.name_prefix}-tg"
  port             = 80
  protocol         = "HTTP"
  protocol_version = "HTTP1"
  vpc_id           = var.vpc_id

  tags = {
    Name = "${local.name_prefix}-tg"
  }
}

resource "aws_lb_target_group_attachment" "this" {
  count            = length(var.target_ids)
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = tolist(var.target_ids)[count.index]
  port             = 80
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = {
    Name = "${local.name_prefix}-listener"
  }
}
