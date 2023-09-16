# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- single-account/modules/compute/main.tf ---

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

resource "aws_vpc_security_group_egress_rule" "allowing_egress_any" {
  security_group_id = aws_security_group.instance_sg.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

# Data resource to determine the latest Amazon Linux2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"
    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"
    values = [
      "amazon",
    ]
  }
}

# EC2 instances
resource "aws_instance" "ec2_instance" {
  count = var.vpc_information.number_azs

  ami                         = data.aws_ami.amazon_linux.id
  associate_public_ip_address = false
  instance_type               = var.vpc_information.instance_type
  vpc_security_group_ids      = [aws_security_group.instance_sg.id]
  subnet_id                   = values({ for k, v in var.vpc.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "workload" })[count.index]
  iam_instance_profile        = var.ec2_iam_instance_profile

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

# ---------- SSM VPC ENDPOINTS ----------
# Local variable: endpoint names
locals {
  endpoint_names = ["ssm", "ssmmessages", "ec2messages"]
}

# Current AWS Region
data "aws_region" "region" {}

# VPC endpoints
resource "aws_vpc_endpoint" "endpoint" {
  for_each = toset(local.endpoint_names)

  vpc_id              = var.vpc.vpc_attributes.id
  service_name        = "com.amazonaws.${data.aws_region.region.name}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = values({ for k, v in var.vpc.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "endpoints" })
  security_group_ids  = [aws_security_group.endpoints_vpc_sg.id]
  private_dns_enabled = true
}

# Security Group
resource "aws_security_group" "endpoints_vpc_sg" {
  name        = "${var.vpc_name}-endpoints-security-group-${var.identifier}"
  description = "VPC endpoint"
  vpc_id      = var.vpc.vpc_attributes.id
}

resource "aws_vpc_security_group_ingress_rule" "allowing_ingress_https" {
  security_group_id = aws_security_group.endpoints_vpc_sg.id

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = var.vpc_information.cidr_block
}