/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

output "spoke_transit_gateway_route_table" {
  description = "Spoke Transit Gateway Route Table"
  value       = aws_ec2_transit_gateway_route_table.spoke_vpc_route_table
}

output "inspection_transit_gateway_route_table_id" {
  description = "Post-Inspection Transit Gateway Route Table"
  value       = aws_ec2_transit_gateway_route_table.post_inspection_vpc_route_table
}