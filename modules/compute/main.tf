/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

# Create an EC2 Security Group
resource "aws_security_group" "instance_security_group" {
  for_each    = var.instance_security_groups
  name        = each.value.name
  description = each.value.description
  vpc_id      = var.vpc_id



  #public Security Group
  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

tags = {
  Name = "${var.name}-instance-security-group"
}


}

# Create an EC2 instance
module "ec2_with_t2_unlimited" {
  source = "terraform-aws-modules/ec2-instance/aws"


  count = length(var.subnet_id)

  name                        = "${var.name}-${count.index + 1}"
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  cpu_credits                 = var.cpu_credits
  subnet_id                   = var.subnet_id[count.index]
  vpc_security_group_ids      = [for i in aws_security_group.instance_security_group : i.id]
  associate_public_ip_address = false
  iam_instance_profile        = var.iam_instance_profile
  key_name                    = var.key_name
}
