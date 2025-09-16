/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

# --- single-account/centralized_egress/outputs.tf ---

output "vpcs" {
  description = "VPCs created."
  value = {
    spokes     = { for k, v in module.spoke_vpcs : k => v.vpc_attributes.id }
    inspection = module.inspection_vpc.vpc_attributes.id
  }
}

output "transit_gateway_id" {
  description = "AWS Transit Gateway ID."
  value       = aws_ec2_transit_gateway.tgw.id
}

output "transit_gateway_route_tables" {
  description = "Transit Gateway Route Table."
  value = {
    inspection = aws_ec2_transit_gateway_route_table.tgw_route_table_inspection.id
    spoke      = aws_ec2_transit_gateway_route_table.tgw_route_table_spoke.id
  }
}

output "instances" {
  description = "EC2 instances created."
  value       = { for k, v in module.compute : k => v.ec2_instances.*.id }
}

output "network_firewall" {
  description = "AWS Network Firewall ID."
  value       = module.network_firewall.aws_network_firewall.id
}
