locals {
  vpc_cidr    = "10.0.0.0/16"
  name_prefix = "${var.app_name}-${var.env}"

  public_east_1a_subnets = [for subnet in module.vpc.public_subnets : subnet.id if subnet.availability_zone == "us-east-1a"]

  public_subnet_by_avl_zone = toset(values({
    for subnet in module.vpc.public_subnets : subnet.availability_zone => subnet.id
  }))

  private_subnet_by_avl_zone = toset(values({
    for subnet in module.vpc.private_subnets : subnet.availability_zone => subnet.id
  }))
}

resource "random_password" "ansible_password" {
  length      = 24
  special     = false
  upper       = true
  lower       = true
  numeric     = true
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
}

resource "aws_secretsmanager_secret" "ansible_password" {
  name_prefix             = "${local.name_prefix}-ansible-password-"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "ansible_password" {
  secret_id                = aws_secretsmanager_secret.ansible_password.id
  secret_string_wo         = random_password.ansible_password.result
  secret_string_wo_version = 1
}

module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = local.vpc_cidr
  region               = var.region
  private_subnet_count = 2
  public_subnet_count  = 2
  avl_zones            = toset(data.aws_availability_zones.available.names)
  name_prefix          = local.name_prefix
}

module "s3_build_files" {
  source             = "./modules/s3"
  force_destroy      = true
  name_prefix        = "${local.name_prefix}-build-files"
  versioning_enabled = true

  default_retention = {
    mode = "COMPLIANCE"
    days = 1
  }

  lifecycle_rules = {
    "archive-old-data" = {
      enabled = true
      transitions = [
        { days = 30, storage_class = "STANDARD_IA" },
        { days = 90, storage_class = "GLACIER" },
        { days = 365, storage_class = "DEEP_ARCHIVE" }
      ]
      expiration                             = { days = 730 }
      abort_incomplete_multipart_upload_days = 7
    }

    "cleanup-old-versions" = {
      enabled = true
      noncurrent_version_expiration = {
        days                     = 30
        newer_versions_to_retain = 3
      }
    }
  }
}

module "rds" {
  source                = "./modules/rds"
  vpc_id                = module.vpc.vpc_id
  instance_class        = "db.t4g.micro"
  engine_version        = "18.1"
  parameter_grp_family  = "postgres18"
  db_name               = var.db_name
  allocated_storage     = 20
  max_allocated_storage = 200
  storage_type          = "gp3"
  subnet_ids            = local.private_subnet_by_avl_zone
  encrypt_storage       = true
  apply_immediately     = true
  skip_final_snapshot   = true
  multi_az              = false
  deletion_protection   = false
  name_prefix           = local.name_prefix
}

module "ec2" {
  source               = "./modules/ec2"
  vpc_id               = module.vpc.vpc_id
  instance_type        = "t3.micro"
  subnets              = length(local.public_east_1a_subnets) > 0 ? [local.public_east_1a_subnets[0]] : [module.vpc.public_subnets[0].id]
  cpu_credits_type     = "standard"
  name_prefix          = local.name_prefix
  key_name             = var.ec2_key_name
  instance_tags        = { Role = "apiserver" }
  enable_ssh           = true
  enable_rdp           = true
  dev_access_cidrs     = tolist(var.josh_ips)
  iam_instance_profile = module.iam_ec2_s3_access.instance_profile_name

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP"
    },
    {
      from_port   = 5985
      to_port     = 5985
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "WinRM HTTP"
    },
    {
      from_port   = 5986
      to_port     = 5986
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "WinRM HTTPS"
    }
  ]

  additional_sg_ids = [module.rds.client_security_group_id]

  user_data = templatefile("${path.root}/templates/ec2_user_data.tftpl", {
    username         = "ansible"
    ansible_password = random_password.ansible_password.result
  })
}

module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.vpc.vpc_id
  subnets           = local.public_subnet_by_avl_zone
  name_prefix       = local.name_prefix
  health_check_path = "/weatherforecast"

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP"
    }
  ]

  target_groups = {
    "dotnetapi" = {
      port             = 80
      protocol         = "HTTP"
      protocol_version = "HTTP1"
      target_ids       = module.ec2.instance_ids
    }
  }

  listeners = {
    "dotnetapi" = {
      port     = 80
      protocol = "HTTP"
    }
  }
}

module "iam_ec2_s3_access" {
  source      = "./modules/iam-role-for-service-accounts"
  name_prefix = local.name_prefix
  role_name   = "ec2-s3-access"

  trusted_services = ["ec2.amazonaws.com"]

  policies = {
    "s3-access" = {
      policy_json = templatefile("${path.root}/policies/ec2-s3-access.json.tftpl", {
        bucket_arn = module.s3_build_files.bucket_arn
      })
    }
  }

  create_instance_profile = true
}
