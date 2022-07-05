/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

# AWS Network Firewall Resource
resource "aws_networkfirewall_firewall" "anfw" {
  name                = "ANFW-${var.vpc_name}-${var.project_name}"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.anfw_policy.arn
  vpc_id              = var.vpc_info.vpc_attributes.id

  dynamic "subnet_mapping" {
    for_each = values({ for k, v in var.vpc_info.private_subnet_attributes_by_az : k => v.id })

    content {
      subnet_id = subnet_mapping.value
    }
  }
}

# Route from the TGW Subnet to 0.0.0.0/0 via the firewall endpoint
resource "aws_route" "tgw_to_firewall_endpoint" {
  count = var.number_azs

  route_table_id         = var.vpc_info.route_table_by_subnet_type.transit_gateway[local.availability_zones[count.index]].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = { for i in aws_networkfirewall_firewall.anfw.firewall_status[0].sync_states : i.availability_zone => i.attachment[0].endpoint_id }[local.availability_zones[count.index]]
}

# Route from the Public Subnet to the Segment CIDR block via the firewall endpoint
resource "aws_route" "public_to_firewall_endpoint" {
  count = var.number_azs

  route_table_id         = var.vpc_info.route_table_by_subnet_type.public[local.availability_zones[count.index]].id
  destination_cidr_block = var.supernet
  vpc_endpoint_id        = { for i in aws_networkfirewall_firewall.anfw.firewall_status[0].sync_states : i.availability_zone => i.attachment[0].endpoint_id }[local.availability_zones[count.index]]
}

