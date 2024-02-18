# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- multi-account/modules/compute/main.tf ---

# ---------- EC2 INSTANCES ----------
# Security Group
resource "aws_security_group" "instance_sg" {
  name        = "${var.vpc_name}-instance-security-group-${var.identifier}"
  description = "EC2 Instance Security Group"
  vpc_id      = var.vpc.vpc_attributes.id
}

resource "aws_vpc_security_group_ingress_rule" "allowing_ingress_icmp" {
  security_group_id = aws_security_group.instance_sg.id

  from_port   = -1
  to_port     = -1
  ip_protocol = "icmp"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "allowing_ingress_eic" {
  security_group_id = aws_security_group.instance_sg.id

  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.eic_sg.id
}

resource "aws_vpc_security_group_egress_rule" "allowing_egress_any" {
  security_group_id = aws_security_group.instance_sg.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

# Data resource to determine the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# EC2 instances
resource "aws_instance" "ec2_instance" {
  count = var.vpc_information.number_azs

  ami                         = data.aws_ami.amazon_linux.id
  associate_public_ip_address = false
  instance_type               = var.vpc_information.instance_type
  vpc_security_group_ids      = [aws_security_group.instance_sg.id]
  subnet_id                   = values({ for k, v in var.vpc.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "private" })[count.index]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "${var.vpc_name}-instance-${count.index + 1}-${var.identifier}"
  }
}

# ---------- EC2 INSTANCE CONNECT ----------
# Security Group
resource "aws_security_group" "eic_sg" {
  name        = "${var.vpc_name}-eic-security-group-${var.identifier}"
  description = "EC2 Instance Connect Security Group"
  vpc_id      = var.vpc.vpc_attributes.id
}

resource "aws_vpc_security_group_egress_rule" "allowing_egress_ec2_instances" {
  security_group_id = aws_security_group.eic_sg.id

  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.instance_sg.id
}

# EC2 Instance Connect endpoint
resource "aws_ec2_instance_connect_endpoint" "eic_endpoint" {
  subnet_id          = values({ for k, v in var.vpc.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "endpoints" })[0]
  preserve_client_ip = false
  security_group_ids = [aws_security_group.eic_sg.id]
}