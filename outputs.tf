/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

output "vpcs" {
  description = "VPCs created."
  value = {
    spokes     = { for k, v in module.spoke_vpcs : k => v.vpc_attributes.id }
    inspection = module.hubspoke.central_vpcs["inspection"].vpc_attributes.id
  }
}

output "transit_gateway_id" {
  description = "AWS Transit Gateway ID."
  value       = module.hubspoke.transit_gateway.id
}

output "transit_gateway_route_tables" {
  description = "Transit Gateway Route Table."
  value = {
    inspection = module.hubspoke.transit_gateway_route_tables.central_vpcs.inspection.id
    spoke      = module.hubspoke.transit_gateway_route_tables.spoke_vpcs.spokes.id
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
  value       = module.hubspoke.aws_network_firewall.id
}
