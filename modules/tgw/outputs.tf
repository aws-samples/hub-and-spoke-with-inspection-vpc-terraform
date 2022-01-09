/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

# VPC
output "tgw_id" {
  description = "The ID of the TGW"
  value       = aws_ec2_transit_gateway.tgw.id
}

output "spoke_transit_gateway_route_table_id" {
  description = "The ID of the Transit Gateway Route Table"
  value       = aws_ec2_transit_gateway_route_table.spoke_vpc_route_table.id
}

output "inspection_transit_gateway_route_table_id" {
  description = "The ID of the Transit Gateway Route Table"
  value       = aws_ec2_transit_gateway_route_table.inspection_vpc_route_table.id
}