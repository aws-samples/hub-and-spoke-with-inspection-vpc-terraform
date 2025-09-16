/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

# --- single-account/centralized_egress/main.tf ---

# ---------- HUB AND SPOKE WITH CENTRAL INSPECTION (AWS NETWORK FIREWALL) ----------
# AWS Transit Gateway
resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "Transit Gateway - ${var.identifier}"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = { Name = "tgw-${var.identifier}" }
}


# Inspection VPC - https://registry.terraform.io/modules/aws-ia/vpc/aws/latest
module "inspection_vpc" {
  source  = "aws-ia/vpc/aws"
  version = "4.5.0"

  name       = "inspection-vpc-${var.identifier}"
  cidr_block = "100.64.0.0/24"
  az_count   = 2

  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  transit_gateway_routes = { endpoints = "10.0.0.0/16" }

  subnets = {
    public = {
      netmask                   = var.inspection_vpc.public_subnet_netmask
      nat_gateway_configuration = "all_azs"
    }
    endpoints = {
      netmask                 = var.inspection_vpc.private_subnet_netmask
      connect_to_public_natgw = true
    }
    transit_gateway = {
      netmask                                         = var.inspection_vpc.tgw_subnet_netmask
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
      transit_gateway_appliance_mode_support          = "enable"
    }
  }
}

# AWS Network Firewall (and related routing) - https://registry.terraform.io/modules/aws-ia/networkfirewall/aws/latest
module "network_firewall" {
  source  = "aws-ia/networkfirewall/aws"
  version = "1.0.2"

  network_firewall_name        = "anfw-${var.identifier}"
  network_firewall_description = "AWS Network Firewall - ${var.identifier}"
  network_firewall_policy      = aws_networkfirewall_firewall_policy.anfw_policy.arn

  vpc_id      = module.inspection_vpc.vpc_attributes.id
  number_azs  = var.inspection_vpc.number_azs
  vpc_subnets = { for k, v in module.inspection_vpc.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "endpoints" }

  routing_configuration = {
    centralized_inspection_with_egress = {
      connectivity_subnet_route_tables = { for k, v in module.inspection_vpc.rt_attributes_by_type_by_az.transit_gateway : k => v.id }
      public_subnet_route_tables       = { for k, v in module.inspection_vpc.rt_attributes_by_type_by_az.public : k => v.id }
      network_cidr_blocks              = ["10.0.0.0/16"]
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
# Spoke VPCs associated and propagating
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

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_spoke_propagation" {
  for_each = var.spoke_vpcs

  transit_gateway_attachment_id  = module.spoke_vpcs[each.key].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table_spoke.id
}

resource "aws_ec2_transit_gateway_route" "tgw_route_default_to_inspection" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = module.inspection_vpc.transit_gateway_attachment_id
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
  transit_gateway_attachment_id  = module.inspection_vpc.transit_gateway_attachment_id
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