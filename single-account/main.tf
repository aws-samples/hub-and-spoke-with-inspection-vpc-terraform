/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

# --- single-account/main.tf ---

# ---------- HUB AND SPOKE WITH CENTRAL INSPECTION (AWS NETWORK FIREWALL) ----------
# Module - https://registry.terraform.io/modules/aws-ia/network-hubandspoke/aws/latest
module "hubspoke" {
  source     = "aws-ia/network-hubandspoke/aws"
  version    = "3.0.2"
  identifier = var.identifier

  transit_gateway_attributes = {
    name        = "tgw-${var.identifier}"
    description = "Transit Gateway - ${var.identifier}"
  }

  network_definition = {
    type  = "CIDR"
    value = "10.0.0.0/16"
  }

  central_vpcs = {
    inspection = {
      name            = "inspection-vpc"
      cidr_block      = var.inspection_vpc.cidr_block
      az_count        = var.inspection_vpc.number_azs
      inspection_flow = "all"

      aws_network_firewall = {
        name        = "anfw-${var.identifier}"
        description = "AWS Network Firewall - ${var.identifier}"
        policy_arn  = aws_networkfirewall_firewall_policy.anfw_policy.arn
      }

      subnets = {
        public          = { netmask = var.inspection_vpc.public_subnet_netmask }
        endpoints       = { netmask = var.inspection_vpc.private_subnet_netmask }
        transit_gateway = { netmask = var.inspection_vpc.tgw_subnet_netmask }
      }
    }
  }

  spoke_vpcs = {
    number_vpcs = length(var.spoke_vpcs)
    vpc_information = { for k, v in module.spoke_vpcs : k => {
      vpc_id                        = v.vpc_attributes.id
      transit_gateway_attachment_id = v.transit_gateway_attachment_id
    } }
  }
}

# ---------- SPOKE VPCs ----------
# Amazon VPC Module - https://registry.terraform.io/modules/aws-ia/vpc/aws/latest
module "spoke_vpcs" {
  for_each = var.spoke_vpcs
  source   = "aws-ia/vpc/aws"
  version  = "= 4.3.0"

  name       = each.key
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  transit_gateway_id = module.hubspoke.transit_gateway.id
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

# ---------- EC2 INSTANCES & SSM VPC ENDPOINTS ----------
module "compute" {
  source   = "../modules/compute"
  for_each = module.spoke_vpcs

  identifier               = var.identifier
  vpc_name                 = each.key
  vpc                      = each.value
  vpc_information          = var.spoke_vpcs[each.key]
  ec2_iam_instance_profile = module.iam_kms.ec2_iam_instance_profile
}

# ---------- IAM ROLE (SSM ACCESS & VPC FLOW LOGS) AND KMS KEY (VPC FLOW LOGS) ----------
module "iam_kms" {
  source = "../modules/iam_kms"

  identifier = var.identifier
  aws_region = var.aws_region
}