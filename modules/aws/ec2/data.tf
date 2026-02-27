data "aws_ec2_instance_type_offerings" "available" {
  filter {
    name   = "instance-type"
    values = [var.instance_type]
  }

  location_type = "availability-zone"
}

data "aws_ami" "opensuse" {
  count = var.certified_os_image ? 0 : 1
  filter {
    name = "name"
    values = ["openSUSE-Leap-15.6-*"]
  }
}