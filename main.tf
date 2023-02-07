/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

/*  The VPC module will deploy a VPC for each resoruce defined in the variables.tf file defined as a spoke
    Additional resources such as NAT Gateways will be deployed according to the value set in the variables file */

# ---------- SPOKE VPCs ----------
# Amazon VPC Module - https://registry.terraform.io/modules/aws-ia/vpc/aws/latest
module "spoke_vpcs" {
  for_each = var.spoke_vpcs
  source   = "aws-ia/vpc/aws"
  version  = "= 3.2.1"

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
    iam_role_arn         = aws_iam_role.vpc_flowlogs_role.id
    kms_key_id           = aws_kms_key.log_key.arn
  }
}

# ---------- EC2 INSTANCES & SECURITY GROUP (in each Spoke VPC) ----------
# Data resource to determine the latest Amazon Linux2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"
    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"
    values = [
      "amazon",
    ]
  }
}

# Security Group - EC2 instance
resource "aws_security_group" "spoke_vpc_sg" {
  for_each = module.spoke_vpcs

  name        = local.security_groups.instance.name
  description = local.security_groups.instance.description
  vpc_id      = each.value.vpc_attributes.id

  dynamic "ingress" {
    for_each = local.security_groups.instance.ingress
    content {
      description = ingress.value.description
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = local.security_groups.instance.egress
    content {
      description = egress.value.description
      from_port   = egress.value.from
      to_port     = egress.value.to
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = {
    Name = "${each.key}-instance-security-group-${var.project_name}"
  }
}

# EC2 Instances (one in each AZ)
module "compute" {
  for_each = module.spoke_vpcs
  source   = "./modules/compute"

  project_name             = var.project_name
  vpc_name                 = each.key
  vpc_id                   = each.value.vpc_attributes.id
  vpc_subnets              = values({ for k, v in each.value.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "workload" })
  number_azs               = var.spoke_vpcs[each.key].number_azs
  instance_type            = var.spoke_vpcs[each.key].instance_type
  ami_id                   = data.aws_ami.amazon_linux.id
  ec2_iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.id
  ec2_security_group       = aws_security_group.spoke_vpc_sg[each.key].id
}

# ---------- VPC ENDPOINTS (in each Spoke VPC) ----------
# VPC Endpoints Security Groups
resource "aws_security_group" "endpoints_vpc_sg" {
  for_each = module.spoke_vpcs

  name        = local.security_groups.endpoints.name
  description = local.security_groups.endpoints.description
  vpc_id      = each.value.vpc_attributes.id

  dynamic "ingress" {
    for_each = local.security_groups.endpoints.ingress
    content {
      description = ingress.value.description
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = local.security_groups.endpoints.egress
    content {
      description = egress.value.description
      from_port   = egress.value.from
      to_port     = egress.value.to
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = {
    Name = "${each.key}-endpoints-security-group-${var.project_name}"
  }
}

# VPC Endpoints
module "vpc_endpoints" {
  for_each = module.spoke_vpcs
  source   = "./modules/endpoints"

  project_name             = var.project_name
  vpc_name                 = each.key
  vpc_id                   = each.value.vpc_attributes.id
  vpc_subnets              = values({ for k, v in each.value.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "endpoints" })
  endpoints_security_group = aws_security_group.endpoints_vpc_sg[each.key].id
  endpoints_service_names  = local.endpoint_service_names
}

# ---------- HUB AND SPOKE WITH CENTRAL INSPECTION (AWS NETWORK FIREWALL) ----------
# Module - https://registry.terraform.io/modules/aws-ia/network-hubandspoke/aws/latest
module "hubspoke" {
  source     = "aws-ia/network-hubandspoke/aws"
  version    = "2.0.0"
  identifier = var.project_name

  transit_gateway_attributes = {
    name        = "tgw-${var.project_name}"
    description = "Transit Gateway - ${var.project_name}"
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
        name       = "anfw-${var.project_name}"
        policy_arn = aws_networkfirewall_firewall_policy.anfw_policy.arn
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

# ---------- EC2 INSTANCE IAM ROLE (SSM ACCESS) ---------
# IAM instance profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile_${var.project_name}"
  role = aws_iam_role.role_ec2.id
}

# IAM role
resource "aws_iam_role" "role_ec2" {
  name               = "ec2_ssm_role_${var.project_name}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.policy_document.json
}

data "aws_iam_policy_document" "policy_document" {
  statement {
    sid     = "1"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

  }
}

# Policies Attachment to Role
resource "aws_iam_policy_attachment" "ssm_iam_role_policy_attachment" {
  name       = "ssm_iam_role_policy_attachment_${var.project_name}"
  roles      = [aws_iam_role.role_ec2.id]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ---------- VPC FLOW LOG - IAM ROLE AND KMS KEY ----------
# Data Source: AWS Caller Identity - Used to get the Account ID
data "aws_caller_identity" "current" {}

# IAM Role
resource "aws_iam_role" "vpc_flowlogs_role" {
  name               = "vpc-flowlog-role-${var.project_name}"
  assume_role_policy = data.aws_iam_policy_document.policy_role_document.json
}

data "aws_iam_policy_document" "policy_role_document" {
  statement {
    sid     = "1"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

# IAM Role Policy
resource "aws_iam_role_policy" "vpc_flowlogs_role_policy" {
  name   = "vpc-flowlog-role-policy-${var.project_name}"
  role   = aws_iam_role.vpc_flowlogs_role.id
  policy = data.aws_iam_policy_document.policy_rolepolicy_document.json
}

data "aws_iam_policy_document" "policy_rolepolicy_document" {
  statement {
    sid = "2"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroup",
      "logs:DescribeLogStreams"
    ]
    resources = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"]
  }
}

# KMS Key
resource "aws_kms_key" "log_key" {
  description             = "KMS Logs Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.policy_kms_logs_document.json

  tags = {
    Name = "kms-key-${var.project_name}"
  }
}

# KMS Policy - it allows the use of the Key by the CloudWatch log groups created in this sample
data "aws_iam_policy_document" "policy_kms_logs_document" {
  statement {
    sid       = "Enable IAM User Permissions"
    actions   = ["kms:*"]
    resources = ["arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid = "Enable KMS to be used by CloudWatch Logs"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:*"]

    principals {
      type        = "Service"
      identifiers = ["logs.${var.region}.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }
}
