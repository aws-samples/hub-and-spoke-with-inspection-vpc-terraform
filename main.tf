/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

/*  The VPC module will deploy a VPC for each resoruce defined in the variables.tf file defined as a spoke
    Additional resources such as NAT Gateways will be deploeyed according to the value set in the variables file */

# Spoke VPCs. Module - https://github.com/aws-ia/terraform-aws-vpc
module "spoke_vpcs" {
  for_each = {
    for k, v in var.vpcs : k => v
    if v.type == "spoke"
  }
  source  = "aws-ia/vpc/aws"
  version = "= 1.4.1"

  name       = each.key
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  subnets = {
    private = {
      name_prefix              = "private"
      netmask                  = each.value.private_subnet_netmask
      route_to_nat             = false
      route_to_transit_gateway = ["0.0.0.0/0"]
    }
    transit_gateway = {
      name_prefix                                     = "tgw"
      netmask                                         = each.value.tgw_subnet_netmask
      transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
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

# Inspection VPC. Module - https://github.com/aws-ia/terraform-aws-vpc
module "inspection_vpc" {
  for_each = {
    for k, v in var.vpcs : k => v
    if v.type == "inspection"
  }
  source  = "aws-ia/vpc/aws"
  version = "= 1.4.1"

  name       = each.key
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  subnets = {
    public = {
      name_prefix               = "public"
      netmask                   = each.value.public_subnet_netmask
      nat_gateway_configuration = "all_azs"
    }

    private = {
      name_prefix              = "inspection"
      netmask                  = each.value.private_subnet_netmask
      route_to_nat             = true
      route_to_transit_gateway = [var.supernet]
    }
    transit_gateway = {
      name_prefix                                     = "tgw"
      netmask                                         = each.value.tgw_subnet_netmask
      transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
      transit_gateway_appliance_mode_support          = "enable"
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
  transit_gateway_attachment_id  = module.inspection_vpc["inspection-vpc"].transit_gateway_attachment_id
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
  transit_gateway_attachment_id  = module.inspection_vpc["inspection-vpc"].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_vpc_route_table.id
}

# The VPC Endpoint module deploys the necessary AWS VPC Endpoints to allow SSM (information of the endpoints to create in locals.tf)
# VPC Endpoints are only deployed into Spoke VPCs
module "vpc_endpoints" {
  for_each = module.spoke_vpcs
  source   = "./modules/endpoints"

  project_name             = var.project_name
  vpc_name                 = each.key
  vpc_id                   = each.value.vpc_attributes.id
  vpc_subnets              = values({ for k, v in each.value.private_subnet_attributes_by_az : k => v.id })
  endpoints_security_group = local.security_groups.endpoints
  endpoints_service_names  = local.endpoint_service_names
}


# The IAM role creates the nessesary policies for the VPC Flow logs and the EC2 instance
module "iam_kms" {
  source = "./modules/iam_kms"

  project_name = var.project_name
  aws_region   = var.region
}

# The Compute module deployes EC2 instances into Spoke VPCs only, the number of instances are defined in variables.tf
module "compute" {
  for_each = module.spoke_vpcs
  source   = "./modules/compute"

  project_name             = var.project_name
  vpc_name                 = each.key
  vpc_id                   = each.value.vpc_attributes.id
  vpc_subnets              = var.ec2_multi_subnet ? values({ for k, v in each.value.private_subnet_attributes_by_az : k => v.id }) : slice(values({ for k, v in each.value.private_subnet_attributes_by_az : k => v.id }), 0, 1)
  number_azs               = var.ec2_multi_subnet ? var.vpcs[each.key].number_azs : 1
  instance_type            = var.vpcs[each.key].instance_type
  ec2_iam_instance_profile = module.iam_kms.ec2_iam_instance_profile
  ec2_security_group       = local.security_groups.instance
}

/* Module to the AWS Network Firewall
   The ANFW policy is defined in the policy.tf file in the aws_network_firewall module directory */
module "aws_network_firewall" {
  source = "./modules/network_firewall"

  project_name    = var.project_name
  vpc_name        = "inspection-vpc"
  vpc_info        = module.inspection_vpc["inspection-vpc"]
  policy_document = aws_networkfirewall_firewall_policy.anfw_policy.arn
  supernet        = var.supernet
  number_azs      = var.vpcs["inspection-vpc"].number_azs
}
