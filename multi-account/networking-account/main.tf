/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- networking-account/main.tf ---

# ---------- AWS ORGANIZATIONS AND ACCOUNT INFORMATION ----------
data "aws_caller_identity" "aws_networking_account" {}
data "aws_organizations_organization" "org" {}

# ---------- AMAZON VPC IPAM ----------
module "ipam" {
  source  = "aws-ia/ipam/aws"
  version = "2.0.0"

  top_cidr       = ["10.0.0.0/8"]
  address_family = "ipv4"
  create_ipam    = true
  top_name       = "Organization IPAM"

  pool_configurations = {
    ireland = {
      name           = "ireland"
      description    = "Ireland (eu-west-1) Region"
      netmask_length = 16
      locale         = var.aws_region

      sub_pools = {
        spoke = {
          name                 = "spoke-accounts"
          netmask_length       = 16
          ram_share_principals = [data.aws_organizations_organization.org.arn]
        }
      }
    }
  }
}

# ---------- HUB AND SPOKE ARCHITECTURE (WITH INSPECTION) --------
# Obtaining Firewall Policy ARN from Secrets Manager secret (shared by Security Account)
data "aws_secretsmanager_secret" "firewall_policy_arn" {
  arn = "arn:aws:secretsmanager:${var.aws_region}:${var.security_account}:secret:${var.secrets_names.security_account}"
}

data "aws_secretsmanager_secret_version" "firewall_policy_arn" {
  secret_id = data.aws_secretsmanager_secret.firewall_policy_arn.id
}

# data "aws_secretsmanager_secret_version" "spoke_attachments" {
#   secret_id = aws_secretsmanager_secret.spoke_attachments.id
# }

# locals {
#   spoke_vpc_information = jsondecode(data.aws_secretsmanager_secret_version.spoke_attachments.secret_string)["spoke_account"]
# }

# Hub and Spoke architecture
module "hubspoke" {
  source  = "aws-ia/network-hubandspoke/aws"
  version = "3.0.2"

  identifier = "hubspoke-${var.identifier}"
  transit_gateway_attributes = {
    name                           = "tgw-${var.identifier}"
    description                    = "Transit Gateway - ${var.identifier}"
    amazon_side_asn                = 65050
    auto_accept_shared_attachments = "enable"
  }

  network_definition = {
    type  = "CIDR"
    value = "10.0.0.0/16"
  }

  central_vpcs = {
    inspection = {
      name            = "inspection-vpc-${var.aws_region}"
      cidr_block      = "100.64.0.0/24"
      az_count        = 2
      inspection_flow = "north-south"

      aws_network_firewall = {
        name        = "anfw-${var.identifier}"
        description = "AWS Network Firewall - ${var.identifier}"
        policy_arn  = data.aws_secretsmanager_secret_version.firewall_policy_arn.secret_string
      }

      subnets = {
        public          = { netmask = 28 }
        endpoints       = { netmask = 28 }
        transit_gateway = { netmask = 28 }
      }
    }
  }

  # spoke_vpcs = {
  #   routing_domains = ["prod", "nonprod"]
  #   number_vpcs     = local.spoke_vpc_information.number_spoke_vpcs
  #   vpc_information = local.spoke_vpc_information.vpc_information
  # }

  tags = {
    team = "networking"
  }
}

# ---------- AWS RAM (TRANSIT GATEWAY) ----------
# Resource Share
resource "aws_ram_resource_share" "resource_share" {
  name                      = "Transit Gateway Resource Share"
  allow_external_principals = false
}

# Principal Association
resource "aws_ram_principal_association" "principal_association" {
  principal          = data.aws_organizations_organization.org.arn
  resource_share_arn = aws_ram_resource_share.resource_share.arn
}

# Resource Association - AWS Transit Gateway
resource "aws_ram_resource_association" "transit_gateway_share" {
  resource_arn       = module.hubspoke.transit_gateway.arn
  resource_share_arn = aws_ram_resource_share.resource_share.arn
}

# ---------- AWS SECRETS MANAGER ----------
# Transit Gateway Secret
resource "aws_secretsmanager_secret" "transit_gateway" {
  name                    = var.secrets_names.networking_account_tgw
  description             = "Transit Gateway (Networking Account)."
  kms_key_id              = aws_kms_key.secrets_key.arn
  policy                  = data.aws_iam_policy_document.secrets_resource_policy_read.json
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "transit_gateway" {
  secret_id     = aws_secretsmanager_secret.transit_gateway.id
  secret_string = module.hubspoke.transit_gateway.id
}

# Spoke VPC Attachment information
resource "aws_secretsmanager_secret" "spoke_attachments" {
  name                    = var.secrets_names.networking_account_attachments
  description             = "VPC Attachments - Spoke Accounts."
  kms_key_id              = aws_kms_key.secrets_key.arn
  policy                  = data.aws_iam_policy_document.secrets_resource_policy_write.json
  recovery_window_in_days = 0
}

# IPAM Pool Secret
resource "aws_secretsmanager_secret" "ipam_pool" {
  name                    = var.secrets_names.networking_account_ipam
  description             = "IPAM Pool (Networking Account)."
  kms_key_id              = aws_kms_key.secrets_key.arn
  policy                  = data.aws_iam_policy_document.secrets_resource_policy_read.json
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "ipam_pool" {
  secret_id     = aws_secretsmanager_secret.ipam_pool.id
  secret_string = module.ipam.pools_level_2["ireland/spoke"].id
}

# Secrets resource policy - Allowing the AWS Organization to read the secret
data "aws_iam_policy_document" "secrets_resource_policy_read" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetResourcePolicy"
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"

      values = ["${data.aws_organizations_organization.org.id}"]
    }
  }
}

# Secrets resource policy - Allowing the Spoke AWS Account to write the secret
data "aws_iam_policy_document" "secrets_resource_policy_write" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetResourcePolicy"
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"

      values = ["${data.aws_organizations_organization.org.id}"]
    }
  }
}

# KMS Key to encrypt the secrets
resource "aws_kms_key" "secrets_key" {
  description             = "KMS Secrets Key - Security Account."
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.policy_kms_document.json

  tags = {
    Name = "kms-key-${var.identifier}"
  }
}

# KMS Policy
data "aws_iam_policy_document" "policy_kms_document" {
  statement {
    sid    = "Enable AWS Secrets Manager secrets decryption."
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:*"
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"

      values = ["secretsmanager.${var.aws_region}.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:SecretARN"

      values = ["arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.aws_networking_account.id}:secret:*"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"

      values = ["${data.aws_organizations_organization.org.id}"]
    }
  }

  statement {
    sid       = "Enable IAM User Permissions"
    actions   = ["kms:*"]
    resources = ["arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.aws_networking_account.id}:*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.aws_networking_account.id}:root"]
    }
  }
}