data "aws_ami" "windows_2025" {
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

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "random_password" "ansible_password" {
  length  = 24
  special = false
  upper   = true
  lower   = true
  numeric = true
  min_lower = 1
  min_upper = 1
  min_numeric = 1
}

resource "aws_instance" "windows_server" {
  count                  = length(var.subnets)
  ami                    = data.aws_ami.windows_2025.id
  instance_type          = "t3.micro"
  subnet_id              = var.subnets[count.index]
  vpc_security_group_ids = var.sg_ids
  key_name               = "terraform-josh"

  user_data = templatefile("${path.module}/setup.tftpl", {
    username = "ansible"
    ansible_password = random_password.ansible_password.result
  })

  tags = {
    Name        = "windows-server"
    Environment = var.env
  }
}
