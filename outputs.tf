/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

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
    spoke           = aws_ec2_transit_gateway_route_table.spoke_vpc_route_table.id
    post-inspection = aws_ec2_transit_gateway_route_table.post_inspection_vpc_route_table.id
  }
}

output "vpc_endpoints" {
  description = "SSM VPC endpoints created."
  value       = { for k, v in module.vpc_endpoints : k => v.endpoint_ids }
}

output "instances" {
  description = "EC2 instances created."
  value       = { for k, v in module.compute : k => v.instances_created.*.id }
}

output "network_firewall" {
  description = "AWS Network Firewall ID."
  value       = module.aws_network_firewall.anfw.id
}
