
locals {
  vpc_cidr = "10.0.0.0/16"
}

resource "random_string" "db_username" {
  count   = var.username == null ? 1 : 0
  length  = 12
  special = false
  upper   = false
  numeric = true
}

resource "random_password" "db_password" {
  count   = var.password == null ? 1 : 0
  length  = 20
  special = true
  upper   = true
  lower   = true
  numeric = true
}

locals {
  db_username = var.username != null ? var.username : random_string.db_username[0].result
  db_password = var.password != null ? var.password : random_password.db_password[0].result
}

module "iam" {
  source            = "./modules/iam"
  state_file_bucket = var.state_file_bucket
}

module "vpc" {
  source               = "./modules/vpc"
  env                  = var.env
  vpc_cidr             = local.vpc_cidr
  region               = var.region
  private_subnet_count = 2
  public_subnet_count  = 2
  avl_zones            = toset(data.aws_availability_zones.available.names)
}

module "sg" {
  source      = "./modules/sg"
  env         = var.env
  vpc_id      = module.vpc.vpc_id
  ingress_ips = var.josh_ips
}

locals {
  public_east_1a_subnets = [for subnet in module.vpc.public_subnets : subnet.id if subnet.availability_zone == "us-east-1a"]

  public_subnet_by_avl_zone = toset(values({
    for subnet in module.vpc.public_subnets : subnet.availability_zone => subnet.id
  }))

  private_subnet_by_avl_zone = toset(values({
    for subnet in module.vpc.private_subnets : subnet.availability_zone => subnet.id
  }))
}



module "ec2" {
  source  = "./modules/ec2"
  env     = var.env
  subnets = length(local.public_east_1a_subnets) > 0 ? [local.public_east_1a_subnets[0]] : [module.vpc.public_subnets[0].id]
  sg_ids  = [module.sg.http_access, module.sg.outbound_access, module.sg.rds_client, module.sg.dev_access]
}

module "alb" {
  source     = "./modules/alb"
  subnets    = local.public_subnet_by_avl_zone
  sg_ids     = [module.sg.http_access, module.sg.outbound_access]
  vpc_id     = module.vpc.vpc_id
  target_ids = module.ec2.instance_ids
  env        = var.env
}

module "rds" {
  source                 = "./modules/rds"
  instance_class         = "db.t3.micro"
  engine                 = "postgres"
  engine_version         = "18.1"
  username               = local.db_username
  password               = local.db_password
  db_name                = var.db_name
  allocated_storage      = 20
  subnet_ids             = local.private_subnet_by_avl_zone
  env                    = var.env
  encrypt_storage         = true
  apply_immediately       = true
  skip_final_snapshot    = true
  vpc_security_group_ids = [module.sg.rds_server]
}
