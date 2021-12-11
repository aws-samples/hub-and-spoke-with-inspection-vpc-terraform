// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# Deploy SSM, SMM Messages, EC2 and EC2 Messages VPC Endpoints
# This provides SSM Connectivity to EC2 Compute Instances

resource "aws_security_group" "endpoint_security_group" {
  for_each    = var.endpoint_security_groups
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
}
module "vpc_endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = var.vpc_id
  security_group_ids = [for i in aws_security_group.endpoint_security_group : i.id]
  endpoints = {
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
      subnet_ids          = var.subnet_ids
    },
    ssmmessages = {
      service             = "ssmmessages"
      private_dns_enabled = true
      subnet_ids          = var.subnet_ids
    },
    ec2 = {
      service             = "ec2"
      private_dns_enabled = true
      subnet_ids          = var.subnet_ids
    },
    ec2messages = {
      service             = "ec2messages"
      private_dns_enabled = true
      subnet_ids          = var.subnet_ids
    }
  }
}
