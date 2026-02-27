locals {
  letters = ["b","c","d","e","f","g","h","i","j","k","l","m","n","o","p"]
  private_ssh_key_path = var.ssh_private_key_path == null ? "${path.cwd}/${var.prefix}-ssh_private_key.pem" : var.ssh_private_key_path
  public_ssh_key_path  = var.ssh_public_key_path == null ? "${path.cwd}/${var.prefix}-ssh_public_key.pem" : var.ssh_public_key_path
  available_azs = data.aws_ec2_instance_type_offerings.available.locations
  selected_az   = length(local.available_azs) > 0 ? local.available_azs[0] : null
  certified_image_name = "opensuse-leap-15-6-harv-cloud-image.x86_64.vhd"
  certified_image_url  = var.certified_os_image ? "https://github.com/rancher/harvester-cloud/releases/download/${var.certified_os_image_tag}/${local.certified_image_name}" : null
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

resource "null_resource" "download_certified_vhd" {
  count = var.certified_os_image ? 1 : 0
  provisioner "local-exec" {
    command = <<-EOT
      set -e
      if [ ! -f "${path.cwd}/${local.certified_image_name}" ]; then
        echo "Downloading certified VHD..."
        curl -L -o "${path.cwd}/${local.certified_image_name}" "${local.certified_image_url}"
      else
        echo "Certified VHD already exists, skipping download"
      fi
    EOT
  }
}

resource "aws_s3_bucket" "images" {
  count = var.certified_os_image ? 1 : 0
  bucket = "opensuse-vhd-${var.prefix}"
}

resource "aws_s3_object" "vhd" {
  count = var.certified_os_image ? 1 : 0
  depends_on = [null_resource.download_certified_vhd]
  bucket = aws_s3_bucket.images[0].id
  key    = "opensuse-harv.vhd"
  source = "${path.cwd}/${local.certified_image_name}"
}

resource "aws_iam_role" "vmimport" {
  count = var.certified_os_image ? 1 : 0
  name = "vmimport"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "vmie.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "vmimport" {
  count = var.certified_os_image ? 1 : 0
  name = "vmimport"
  role = aws_iam_role.vmimport[0].id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.images[0].arn,
          "${aws_s3_bucket.images[0].arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:ModifySnapshotAttribute",
          "ec2:CopySnapshot",
          "ec2:RegisterImage",
          "ec2:Describe*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_ebs_snapshot_import" "opensuse_snapshot" {
  count = var.certified_os_image ? 1 : 0
  description = "Opensuse Cerfied Image for Harvester cloud"
  role_name = aws_iam_role.vmimport[0].name
  disk_container {
    format = "VHD"
    user_bucket {
      s3_bucket = aws_s3_bucket.images[0].id
      s3_key    = aws_s3_object.vhd[0].key
    }
  }
  depends_on = [aws_s3_object.vhd]
}

resource "aws_ami" "opensuse_ami" {
  count = var.certified_os_image ? 1 : 0
  name               = "opensuse-harv-ami"
  virtualization_type = "hvm"
  root_device_name    = "/dev/xvda"
  ena_support = true
  ebs_block_device {
    device_name = "/dev/xvda"
    snapshot_id = aws_ebs_snapshot_import.opensuse_snapshot[0].id
    volume_size = 2
    volume_type = "gp3"
  }
  tags = {
    Name = "${var.prefix}-ami"
  }
}


resource "aws_vpc" "vpc" {
  cidr_block = "${var.ip_cidr_range}/24"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "${var.ip_cidr_range}/25"
  map_public_ip_on_launch = true
  availability_zone = local.available_azs[0]
  tags = {
    Name = "${var.prefix}-subnet"
  }
  lifecycle {
    precondition {
      condition     = local.selected_az != null
      error_message = "No availability zones in this region support instance type ${var.instance_type}"
    }
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

  ingress {
    description = "Allow all inbound WebSocket to nodes"
    from_port   = "6080"
    to_port     = "6080"
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

resource "aws_eip" "static_ip" {
  domain = "vpc"
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.vm.id
  allocation_id = aws_eip.static_ip.id
}

resource "aws_instance" "vm" {
  ami                         = var.certified_os_image ? aws_ami.opensuse_ami[0].id : data.aws_ami.opensuse[0].id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  associate_public_ip_address = false
  key_name                    = var.create_ssh_key_pair ? aws_key_pair.generated[0].key_name : null
  tags = {
    Name = "${var.prefix}-vm"
  }

  cpu_options {
    nested_virtualization = "enabled"
  }

  root_block_device {
    volume_size = var.os_disk_size
    volume_type = "gp3"
  }

  instance_market_options {
    market_type = var.spot_instance ? "spot" : null
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

resource "null_resource" "startup_configuration" {
  depends_on = [aws_volume_attachment.data_attach]
  connection {
    type        = "ssh"
    host        = aws_eip.static_ip.public_ip
    user        = var.certified_os_image ? "opensuse" : "ec2-user"
    timeout     = "5m"
    private_key = var.create_ssh_key_pair ? tls_private_key.ssh[0].private_key_openssh :  null
  }
  provisioner "file" {
    source      = var.startup_script
    destination = "/tmp/startup_script.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "echo 'Executing the OpenSUSE startup_script...'",
      "sudo chmod +x /tmp/startup_script.sh > /dev/null 2>&1",
      "sudo bash /tmp/startup_script.sh > /dev/null 2>&1"
    ]
  }
}

resource "null_resource" "cleanup_certified_vhd" {
  depends_on = [null_resource.startup_configuration]
  count      = var.certified_os_image ? 1 : 0
  provisioner "local-exec" {
    command = "rm ${path.cwd}/opensuse-leap-15-6-harv-cloud-image.x86_64.vhd"
  }
}