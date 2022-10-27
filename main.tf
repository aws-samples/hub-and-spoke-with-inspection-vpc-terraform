/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

/*  The VPC module will deploy a VPC for each resoruce defined in the variables.tf file defined as a spoke
    Additional resources such as NAT Gateways will be deployed according to the value set in the variables file */

# Inspection VPC. Module - https://registry.terraform.io/modules/aws-ia/vpc/aws/latest
module "inspection_vpc" {
  source  = "aws-ia/vpc/aws"
  version = "= 3.0.1"

  name       = "inspection-vpc"
  cidr_block = var.inspection_vpc.cidr_block
  az_count   = var.inspection_vpc.number_azs

  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  transit_gateway_routes = {
    inspection = aws_ec2_managed_prefix_list.prefix_list.id
  }

  subnets = {
    public = {
      netmask                   = var.inspection_vpc.public_subnet_netmask
      nat_gateway_configuration = "all_azs"
    }
    inspection = {
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

  vpc_flow_logs = {
    log_destination_type = var.inspection_vpc.flow_log_config.log_destination_type
    retention_in_days    = var.inspection_vpc.flow_log_config.retention_in_days
    iam_role_arn         = module.iam_kms.vpc_flowlog_role
    kms_key_id           = module.iam_kms.kms_arn
  }
}

# Spoke VPCs. Module - https://registry.terraform.io/modules/aws-ia/vpc/aws/latest
module "spoke_vpcs" {
  for_each = var.spoke_vpcs
  source   = "aws-ia/vpc/aws"
  version  = "= 3.0.1"

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
    iam_role_arn         = module.iam_kms.vpc_flowlog_role
    kms_key_id           = module.iam_kms.kms_arn
  }
}

# AWS Transit Gateway
resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "Transit Gateway - ${var.project_name}"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = {
    Name = "tgw-${var.project_name}"
  }
}

# MANAGED PREFIX LIST (with the Spoke VPCs CIDRs)
# Managed Prefix List resource
resource "aws_ec2_managed_prefix_list" "prefix_list" {
  name           = "Spoke VPCs"
  address_family = "IPv4"
  max_entries    = length(var.spoke_vpcs)
}

resource "aws_ec2_managed_prefix_list_entry" "pl_entry" {
  for_each = var.spoke_vpcs

  cidr           = each.value.cidr_block
  description    = each.key
  prefix_list_id = aws_ec2_managed_prefix_list.prefix_list.id
}

# TRANSIT GATEWAY ROUTING
# Spoke Transit Gateway Route Table
resource "aws_ec2_transit_gateway_route_table" "spoke_vpc_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  tags = {
    Name = "Spoke_Route_Table"
  }
}

# Post-Inspection Transit Gateway Route Table
resource "aws_ec2_transit_gateway_route_table" "post_inspection_vpc_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  tags = {
    Name = "Post_Inspection_Route_Table"
  }
}

# TGW Route Table Association - Spoke VPCs
resource "aws_ec2_transit_gateway_route_table_association" "spoke_tgw_association" {
  for_each = { for k, v in module.spoke_vpcs : k => v.transit_gateway_attachment_id }

  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_vpc_route_table.id
}

# TGW Route Table Association - Inspection VPC
resource "aws_ec2_transit_gateway_route_table_association" "inspection_tgw_association" {
  transit_gateway_attachment_id  = module.inspection_vpc.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.post_inspection_vpc_route_table.id
}

# All the Spoke VPCs propagate to the Post-Inspection Transit Gateway Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_propagation_to_post_inspection" {
  for_each = { for k, v in module.spoke_vpcs : k => v.transit_gateway_attachment_id }

  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.post_inspection_vpc_route_table.id
}

# Static Route (0.0.0.0/0) in the Spoke TGW Route Table sending all the traffic to the Inspection VPC
resource "aws_ec2_transit_gateway_route" "default_route_spoke_to_inspection" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = module.inspection_vpc.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_vpc_route_table.id
}

# AWS Network Firewall module - https://registry.terraform.io/modules/aws-ia/networkfirewall/aws/latest
module "aws_network_firewall" {
  source  = "aws-ia/networkfirewall/aws"
  version = "0.0.2"

  network_firewall_name   = "anfw-${var.project_name}"
  network_firewall_policy = aws_networkfirewall_firewall_policy.anfw_policy.arn

  number_azs  = var.inspection_vpc.number_azs
  vpc_id      = module.inspection_vpc.vpc_attributes.id
  vpc_subnets = { for k, v in module.inspection_vpc.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "inspection" }

  routing_configuration = {
    centralized_inspection_with_egress = {
      tgw_subnet_route_tables    = { for k, v in module.inspection_vpc.rt_attributes_by_type_by_az.transit_gateway : k => v.id }
      public_subnet_route_tables = { for k, v in module.inspection_vpc.rt_attributes_by_type_by_az.public : k => v.id }
      network_cidr_blocks        = values({ for k, v in var.spoke_vpcs : k => v.cidr_block })
    }
  }
}

# The VPC Endpoint module deploys the necessary AWS VPC Endpoints to allow SSM (information of the endpoints to create in locals.tf)
# VPC Endpoints are only deployed into Spoke VPCs
module "vpc_endpoints" {
  for_each = module.spoke_vpcs
  source   = "./modules/endpoints"

  project_name             = var.project_name
  vpc_name                 = each.key
  vpc_id                   = each.value.vpc_attributes.id
  vpc_subnets              = values({ for k, v in each.value.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "endpoints" })
  endpoints_security_group = local.security_groups.endpoints
  endpoints_service_names  = local.endpoint_service_names
}

# The Compute module deployes EC2 instances into Spoke VPCs only, the number of instances are defined in variables.tf
module "compute" {
  for_each = module.spoke_vpcs
  source   = "./modules/compute"

  project_name             = var.project_name
  vpc_name                 = each.key
  vpc_id                   = each.value.vpc_attributes.id
  vpc_subnets              = values({ for k, v in each.value.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "workload" })
  number_azs               = var.spoke_vpcs[each.key].number_azs
  instance_type            = var.spoke_vpcs[each.key].instance_type
  ec2_iam_instance_profile = module.iam_kms.ec2_iam_instance_profile
  ec2_security_group       = local.security_groups.instance
}

# The IAM role creates the nessesary policies for the VPC Flow logs and the EC2 instance
module "iam_kms" {
  source = "./modules/iam_kms"

  project_name = var.project_name
  aws_region   = var.region
}
