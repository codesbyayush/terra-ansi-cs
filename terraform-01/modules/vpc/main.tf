resource "aws_vpc" "vpc_main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = "VPC Main"
    Environment = var.env
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name        = "Internet Gateway"
    Environment = var.env
  }
}

# resource "aws_eip" "nat_eip" {
#   domain   = "vpc"

#   tags = {
#     Name        = "NAT eip"
#     Environment = var.env
#   }
# }

# resource "aws_nat_gateway" "nat" {
#   allocation_id = aws_eip.nat_eip.id
#   subnet_id     = aws_subnet.public[0].id

#   depends_on = [aws_internet_gateway.igw]

#   tags = {
#     Name        = "NAT GW"
#     Environment = var.env
#   }
# }



resource "aws_route_table" "public_rt" {
  for_each = toset([for subnet in aws_subnet.public : subnet.availability_zone])
  vpc_id   = aws_vpc.vpc_main.id

  tags = {
    Name        = "RT Public ${each.key}"
    Scope       = "public"
    Environment = var.env
  }
}

resource "aws_route" "public_route" {
  count               = length(aws_subnet.public)
  route_table_id         = aws_route_table.public_rt[aws_subnet.public[count.index].availability_zone].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_route_assoc" {
  count       = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt[aws_subnet.public[count.index].availability_zone].id
}

resource "aws_route_table" "private_rt" {
  for_each = toset([for subnet in aws_subnet.private : subnet.availability_zone])
  vpc_id   = aws_vpc.vpc_main.id

  tags = {
    Name        = "RT Private ${each.key}"
    Scope       = "private"
    Environment = var.env
  }
}

# resource "aws_route" "private_route" {
#   count               = length(aws_subnet.private)
#   route_table_id         = aws_route_table.private_rt[aws_subnet.private[count.index].availability_zone].id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.nat.id
# }

resource "aws_route_table_association" "private_route_assoc" {
  count       = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt[aws_subnet.private[count.index].availability_zone].id
}

resource "aws_subnet" "public" {
  count = var.public_subnet_count

  vpc_id            = aws_vpc.vpc_main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, ceil(log(var.public_subnet_count + var.private_subnet_count, 2)), count.index)
  availability_zone = tolist(var.avl_zones)[count.index % length(var.avl_zones)]

  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count = var.private_subnet_count

  vpc_id            = aws_vpc.vpc_main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, ceil(log(var.public_subnet_count + var.private_subnet_count, 2)), count.index + var.public_subnet_count)
  availability_zone = tolist(var.avl_zones)[count.index % length(var.avl_zones)]
}
