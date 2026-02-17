data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  name_regex  = "^al2023-ami-.*-x86_64"

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_ami" "custom_ami" {
  count = var.bastion_ami == "" ? 0 : 1
  filter {
    name   = "image-id"
    values = [var.bastion_ami]
  }
}

locals {
  bastion_ami = var.bastion_ami == "" ? data.aws_ami.amazon_linux : data.aws_ami.custom_ami[0]
}

data "aws_subnet" "subnets" {
  count = length(var.elb_subnets)
  id    = var.elb_subnets[count.index]
}

