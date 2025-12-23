locals {
  name_prefix   = "${var.name_prefix}-vpc"
  subnet_bits   = ceil(log(var.public_subnet_count + var.private_subnet_count, 2))
  avl_zone_list = tolist(var.avl_zones)
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = local.name_prefix
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}


resource "aws_route_table" "public" {
  for_each = toset([for subnet in aws_subnet.public : subnet.availability_zone])
  vpc_id   = aws_vpc.this.id

  tags = {
    Name  = "${local.name_prefix}-rt-public-${each.key}"
    Scope = "public"
  }
}

resource "aws_route" "public" {
  count                  = length(aws_subnet.public)
  route_table_id         = aws_route_table.public[aws_subnet.public[count.index].availability_zone].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[aws_subnet.public[count.index].availability_zone].id
}

resource "aws_route_table" "private" {
  for_each = toset([for subnet in aws_subnet.private : subnet.availability_zone])
  vpc_id   = aws_vpc.this.id

  tags = {
    Name  = "${local.name_prefix}-rt-private-${each.key}"
    Scope = "private"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[aws_subnet.private[count.index].availability_zone].id
}

resource "aws_subnet" "public" {
  count = var.public_subnet_count

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, local.subnet_bits, count.index)
  availability_zone = local.avl_zone_list[count.index % length(local.avl_zone_list)]

  map_public_ip_on_launch = true

  tags = {
    Name  = "${local.name_prefix}-subnet-public-${count.index + 1}"
    Scope = "public"
  }
}

resource "aws_subnet" "private" {
  count = var.private_subnet_count

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, local.subnet_bits, var.public_subnet_count + count.index)
  availability_zone = local.avl_zone_list[count.index % length(local.avl_zone_list)]

  tags = {
    Name  = "${local.name_prefix}-subnet-private-${count.index + 1}"
    Scope = "private"
  }
}
