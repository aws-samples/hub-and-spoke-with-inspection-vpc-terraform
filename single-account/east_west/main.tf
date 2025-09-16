/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

# --- single-account/east_west/main.tf ---

data "aws_availability_zones" "azs" {
  state = "available"
}

# ---------- HUB AND SPOKE WITH CENTRAL INSPECTION (AWS NETWORK FIREWALL) ----------
# AWS Transit Gateway
resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "Transit Gateway - ${var.identifier}"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = { Name = "tgw-${var.identifier}" }
}

# AWS Network Firewall (native attachment)
resource "aws_networkfirewall_firewall" "anfw" {
  name                = "anfw-${var.identifier}"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.anfw_policy.arn
  transit_gateway_id  = aws_ec2_transit_gateway.tgw.id

  dynamic "availability_zone_mapping" {
    for_each = { for index, v in toset(data.aws_availability_zones.azs.zone_ids) : index => v }
    iterator = az

    content {
      availability_zone_id = az.value
    }
  }
}

# ---------- SPOKE VPCs ----------
# Amazon VPC Module - https://registry.terraform.io/modules/aws-ia/vpc/aws/latest
module "spoke_vpcs" {
  for_each = var.spoke_vpcs
  source   = "aws-ia/vpc/aws"
  version  = "= 4.5.0"

  name       = each.key
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  transit_gateway_routes = {
    workload = "0.0.0.0/0"
  }

  subnets = {
    workload  = { netmask = each.value.workload_subnet_netmask }
    endpoints = { netmask = each.value.endpoint_subnet_netmask }
    transit_gateway = {
      netmask                                         = each.value.tgw_subnet_netmask
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
    }
  }

  vpc_flow_logs = {
    log_destination_type = each.value.flow_log_config.log_destination_type
    retention_in_days    = each.value.flow_log_config.retention_in_days
    iam_role_arn         = module.iam_kms.vpc_flowlogs_role
    kms_key_id           = module.iam_kms.kms_key
  }
}

# ---------- TRANSIT GATEWAY ROUTING ----------
# Spoke Route Table
# Spoke VPCs associated
# Static route: 0.0.0.0/0 --> Inspection VPC attachment
resource "aws_ec2_transit_gateway_route_table" "tgw_route_table_spoke" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  tags = { Name = "spoke-rt-${var.identifier}" }
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw_spoke_association" {
  for_each = var.spoke_vpcs

  transit_gateway_attachment_id  = module.spoke_vpcs[each.key].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table_spoke.id
}

resource "aws_ec2_transit_gateway_route" "tgw_route_default_to_inspection" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_networkfirewall_firewall.anfw.firewall_status[0].transit_gateway_attachment_sync_states[0].attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table_spoke.id
}

# Inspection Route Table
# Inspection VPC associated
# Spoke VPCs propagating
resource "aws_ec2_transit_gateway_route_table" "tgw_route_table_inspection" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  tags = { Name = "inspection-rt-${var.identifier}" }
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw_inspection_association" {
  transit_gateway_attachment_id  = aws_networkfirewall_firewall.anfw.firewall_status[0].transit_gateway_attachment_sync_states[0].attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table_inspection.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_spoke_propagation_inspection" {
  for_each = var.spoke_vpcs

  transit_gateway_attachment_id  = module.spoke_vpcs[each.key].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table_inspection.id
}

# ---------- EC2 INSTANCES & EC2 INSTANCE CONNECT ENDPOINT ----------
module "compute" {
  source   = "../modules/compute"
  for_each = module.spoke_vpcs

  identifier      = var.identifier
  vpc_name        = each.key
  vpc             = each.value
  vpc_information = var.spoke_vpcs[each.key]
}

# ---------- IAM ROLE (SSM ACCESS & VPC FLOW LOGS) AND KMS KEY (VPC FLOW LOGS) ----------
module "iam_kms" {
  source = "../modules/iam_kms"

  identifier = var.identifier
  aws_region = var.aws_region
}