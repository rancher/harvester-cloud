locals {
  letters = ["b","c","d","e","f","g","h","i","j","k","l","m","n","o","p"]
  private_ssh_key_path = var.ssh_private_key_path == null ? "${path.cwd}/${var.prefix}-ssh_private_key.pem" : var.ssh_private_key_path
  public_ssh_key_path  = var.ssh_public_key_path == null ? "${path.cwd}/${var.prefix}-ssh_public_key.pem" : var.ssh_public_key_path
}

resource "tls_private_key" "ssh" {
  count     = var.create_ssh_key_pair ? 1 : 0
  algorithm = "ED25519"
}

resource "aws_key_pair" "generated" {
  count      = var.create_ssh_key_pair ? 1 : 0
  key_name   = "${var.prefix}-key"
  public_key = tls_private_key.ssh[0].public_key_openssh
}

resource "local_file" "private_key_pem" {
  count           = var.create_ssh_key_pair ? 1 : 0
  filename        = local.private_ssh_key_path
  content         = tls_private_key.ssh[0].private_key_openssh
  file_permission = "0600"
}

resource "local_file" "public_key_pem" {
  count           = var.create_ssh_key_pair ? 1 : 0
  filename        = local.public_ssh_key_path
  content         = tls_private_key.ssh[0].public_key_openssh
  file_permission = "0600"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/25"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.prefix}-subnet"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.prefix}-internet-gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
}

resource "aws_route_table_association" "assoc" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "sg" {
  name   = "${var.prefix}-sg"
  vpc_id = aws_vpc.vpc.id
  ingress {
    description = "Allow all inbound from nodes in the cluster"
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    self        = true
  }

  ingress {
    description = "Allow all inbound SSH to nodes"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow all inbound kube-apiserver to nodes"
    from_port   = "6443"
    to_port     = "6443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow all inbound HTTP to nodes"
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow all inbound HTTPS to nodes"
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-firewall"
  }
}

resource "aws_instance" "vm" {
  ami                         = data.aws_ssm_parameter.sles.insecure_value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  associate_public_ip_address = true
  key_name                    = var.create_ssh_key_pair ? aws_key_pair.generated[0].key_name : null
  user_data              = var.startup_script
  tags = {
    Name = "${var.prefix}-vm"
  }

  # cpu_options {
  #   nested_virtualization = "enabled"
  # }

  root_block_device {
    volume_size = var.os_disk_size
    volume_type = "gp3"
  }

  instance_market_options {
    market_type = var.spot_instance ? "spot" : null
  }

  provisioner "remote-exec" {
    inline = flatten([
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait > /dev/null",
      "echo 'Completed cloud-init!'"
    ])

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = var.create_ssh_key_pair ? tls_private_key.ssh[0].private_key_openssh :  null
    }
  }
}
resource "aws_ebs_volume" "data" {
  count             = var.data_disk_count
  availability_zone = aws_instance.vm.availability_zone
  size              = var.data_disk_size
  type              = "gp3"

  tags = {
    Name = "${var.prefix}-vm"
  }
}

resource "aws_volume_attachment" "data_attach" {
  count       = var.data_disk_count
  device_name = "/dev/sd${local.letters[count.index]}"
  volume_id   = aws_ebs_volume.data[count.index].id
  instance_id = aws_instance.vm.id
}