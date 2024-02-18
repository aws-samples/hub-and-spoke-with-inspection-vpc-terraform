/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- spoke-account/main.tf ---

# ---------- AWS ORGANIZATIONS AND ACCOUNT INFORMATION ----------
data "aws_caller_identity" "aws_spoke_account" {}

# ---------- AMAZON VPCs ----------
# We obtain the Transit Gateway ID and IPAM Pool ID information
data "aws_secretsmanager_secret" "tgw_id" {
  arn = "arn:aws:secretsmanager:${var.aws_region}:${var.networking_account}:secret:${var.secrets_names.networking_account_tgw}"
}

data "aws_secretsmanager_secret_version" "tgw_id" {
  secret_id = data.aws_secretsmanager_secret.tgw_id.id
}

data "aws_secretsmanager_secret" "ipam_pool_id" {
  arn = "arn:aws:secretsmanager:${var.aws_region}:${var.networking_account}:secret:${var.secrets_names.networking_account_ipam}"
}

data "aws_secretsmanager_secret_version" "ipam_pool_id" {
  secret_id = data.aws_secretsmanager_secret.ipam_pool_id.id
}

# VPCs
module "vpcs" {
  source   = "aws-ia/vpc/aws"
  version  = "4.4.2"
  for_each = var.vpcs

  name                    = each.key
  az_count                = 3
  vpc_ipv4_ipam_pool_id   = data.aws_secretsmanager_secret_version.ipam_pool_id.secret_string
  vpc_ipv4_netmask_length = 24

  transit_gateway_id = data.aws_secretsmanager_secret_version.tgw_id.secret_string
  transit_gateway_routes = {
    private = "0.0.0.0/0"
  }

  subnets = {
    endpoints       = { netmask = 28 }
    private         = { netmask = 28 }
    transit_gateway = { 
      netmask = 28 
    
      tags = { domain = var.vpcs[each.key].routing_domain }
    }
  }

  tags = {
    domain = each.value.routing_domain
  }
}

# ---------- INCLUDE VPC INFORMATION IN SECRET ----------
# We retrieve the Secrets Manager secret created by the Central Account
data "aws_secretsmanager_secret" "vpc_information" {
  arn = "arn:aws:secretsmanager:${var.aws_region}:${var.networking_account}:secret:${var.secrets_names.networking_account_attachments}"
}

# We generate the secret we want to pass - with the Spoke VPCs information
locals {
  vpc_information = {
    spoke_account = {
      id                = data.aws_caller_identity.aws_spoke_account.id
      number_spoke_vpcs = length(var.vpcs)
      vpc_information = { for k, v in module.vpcs : k => {
        vpc_id                        = v.vpc_attributes.id
        transit_gateway_attachment_id = v.transit_gateway_attachment_id
        routing_domain                = var.vpcs[k].routing_domain
      } }
    }
  }
}

# We add the secret value to the secret
resource "aws_secretsmanager_secret_version" "vpc_information" {
  secret_id     = data.aws_secretsmanager_secret.vpc_information.id
  secret_string = jsonencode(local.vpc_information)
}

# ---------- EC2 INSTANCES ----------
module "compute" {
  source   = "../modules/compute"
  for_each = module.vpcs

  identifier               = var.identifier
  vpc_name                 = each.key
  vpc                      = each.value
  vpc_information          = var.vpcs[each.key]
}