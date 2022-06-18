/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

# Spoke Transit Gateway Route Table
resource "aws_ec2_transit_gateway_route_table" "spoke_vpc_route_table" {
  transit_gateway_id = var.transit_gateway_id

  tags = {
    Name = "Spoke_Route_Table"
  }
}

# Post-Inspection Transit Gateway Route Table
resource "aws_ec2_transit_gateway_route_table" "post_inspection_vpc_route_table" {
  transit_gateway_id = var.transit_gateway_id

  tags = {
    Name = "Post_Inspection_Route_Table"
  }
}

# TGW Route Table Association - Spoke VPCs
resource "aws_ec2_transit_gateway_route_table_association" "spoke_tgw_association" {
  for_each = var.tgw_spoke_attachments

  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_vpc_route_table.id
}

# TGW Route Table Association - Inspection VPC
resource "aws_ec2_transit_gateway_route_table_association" "inspection_tgw_association" {
  transit_gateway_attachment_id  = var.tgw_inspection_attachment
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.post_inspection_vpc_route_table.id
}

# All the Spoke VPCs propagate to the Post-Inspection Transit Gateway Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_propagation_to_post_inspection" {
  for_each = var.tgw_spoke_attachments

  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.post_inspection_vpc_route_table.id
}

# Static Route (0.0.0.0/0) in the Spoke TGW Route Table sending all the traffic to the Inspection VPC
resource "aws_ec2_transit_gateway_route" "default_route_spoke_to_inspection" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = var.tgw_inspection_attachment
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_vpc_route_table.id
}