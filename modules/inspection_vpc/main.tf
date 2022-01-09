/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

# Attach each Spoke to the TGW using their Intra (VPC Attachment) Subnets
resource "aws_ec2_transit_gateway_vpc_attachment" "inspection_vpc_attachment" {
  transit_gateway_id                              = var.transit_gateway_id
  subnet_ids                                      = var.transit_gateway_attach_subnets
  vpc_id                                          = var.vpc_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name = "${var.name}-attachment"
  }
}
# Associate the Transit Gateway Route Table with each Spoke VPC
resource "aws_ec2_transit_gateway_route_table_association" "inspection_vpc_attachment_rt_association" {
  for_each                       = { for k, v in aws_ec2_transit_gateway_vpc_attachment.inspection_vpc_attachment : k => v if k == "id" }
  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = var.spoke_transit_gateway_route_table_id
}

# resource "aws_route_table" "inspection_vpc_tgw_subnet_route_table" {
resource "aws_route" "attachment_subnet_default_route" {
  route_table_id         = var.intra_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  # https://github.com/hashicorp/terraform-provider-aws/issues/16759
  vpc_endpoint_id = element(local.firewall_vpc_endpoint_descriptions, 0)
}

resource "aws_route" "private_subnet_internal_cidr_route" {
  count                  = length(var.spoke_vpc_cidr_blocks)
  route_table_id         = var.private_route_table_id
  destination_cidr_block = element(var.spoke_vpc_cidr_blocks, count.index)
  transit_gateway_id     = var.transit_gateway_id
}

# "terraform-aws-modules/vpc/aws" creates default route to the NAT Gateway in for the Private Subnet

resource "aws_route" "public_subnet_internal_route" {
  count                  = length(var.spoke_vpc_cidr_blocks)
  route_table_id         = var.public_route_table_id
  destination_cidr_block = element(var.spoke_vpc_cidr_blocks, count.index)
  # https://github.com/hashicorp/terraform-provider-aws/issues/16759
  vpc_endpoint_id = element(local.firewall_vpc_endpoint_descriptions, 0)
}
