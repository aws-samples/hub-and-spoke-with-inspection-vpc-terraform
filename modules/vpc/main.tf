/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

locals {
  name = "project"
  tags = {
    Owner       = "user"
    Environment = "development"
    Provisioner = "terraform"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Create VPC with Public, Private and Intra subnets, intra_subnets created will be used as the VPC to Transit Gateway Attachments
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.name

  create_igw                 = var.create_igw
  enable_nat_gateway         = var.enable_nat_gateway
  single_nat_gateway         = var.single_nat_gateway
  enable_dns_hostnames       = var.enable_dns_hostnames
  enable_dns_support         = var.enable_dns_support
  manage_default_route_table = var.manage_default_route_table
  map_public_ip_on_launch    = var.map_public_ip_on_launch

  cidr                  = var.cidr_block
  azs                   = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets       = [for i in range(1, 4) : cidrsubnet(var.cidr_block, 8, i)]
  public_subnets        = [for i in range(129, 132) : cidrsubnet(var.cidr_block, 8, i)]
  intra_subnets         = [for i in range(200, 203) : cidrsubnet(var.cidr_block, 8, i)]
  private_subnet_suffix = var.private_subnet_suffix
  public_subnet_suffix  = var.public_subnet_suffix
  intra_subnet_suffix   = var.intra_subnet_suffix

  manage_default_security_group = false

  # VPC Flow Logs
  enable_flow_log                      = var.enable_flow_log
  create_flow_log_cloudwatch_log_group = var.create_flow_log_cloudwatch_log_group
  create_flow_log_cloudwatch_iam_role  = var.create_flow_log_cloudwatch_iam_role
  flow_log_max_aggregation_interval    = var.flow_log_max_aggregation_interval

  tags = local.tags
}

resource "aws_security_group" "vpc_security_group" {
  for_each    = var.vpc_security_groups
  name        = each.value.name
  description = each.value.description
  vpc_id      = module.vpc.vpc_id


  #public Security Group
  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}
