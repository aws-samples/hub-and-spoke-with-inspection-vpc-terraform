/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

# Create a single Trasit Gateway for the Hub and Spoke architecture
resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "Transit Gateway"
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  tags                            = var.tags
}

# Create a Spoke Transit Gateway Route Table
resource "aws_ec2_transit_gateway_route_table" "spoke_vpc_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags = {
    Name = "Spoke_VPC_Route_Table"
  }
}

# Create a Spoke Transit Gateway Route Table
resource "aws_ec2_transit_gateway_route_table" "inspection_vpc_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags = {
    Name = "Inspection_VPC_Route_Table"
  }
}

# Propogate the Transit Gateway Route Table with each Spoke VPC Prefix
resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_route_table_propagation_to_inspection_vpc" {
  transit_gateway_attachment_id  = var.inspection_vpc_attachment
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_vpc_route_table.id
}

# Propogate the Transit Gateway Route Table with each Spoke VPC Prefix
resource "aws_ec2_transit_gateway_route_table_propagation" "inspection_route_table_propagation_to_spoke_vpc" {
  for_each                       = var.spoke_vpc_attachments
  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_vpc_route_table.id
}

resource "aws_ec2_transit_gateway_route" "spoke_default_route_to_inspection_vpc" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = var.inspection_vpc_attachment
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_vpc_route_table.id
}