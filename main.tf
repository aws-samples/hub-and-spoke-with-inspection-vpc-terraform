/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

/*  The VPC module will deploy a VPC for each resoruce defined in the variables.tf file defined as a spoke
    Additional resources such as NAT Gateways will be deploeyed according to the value set in the variables file */

# Define the private key algorithm
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

# Use the random pet name as the EC2 instance name
resource "random_pet" "key_name" {
  length = 2
}

# Create an AWS SSH keypair for the EC2 instance
module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = random_pet.key_name.id
  public_key = tls_private_key.private_key.public_key_openssh
  tags = {
    Provisioner = "Terraform"
  }
}

# Save the AWS SSH keypair to a local file
resource "local_file" "private_key" {
  content         = tls_private_key.private_key.public_key_openssh
  filename        = "./keys/${module.key_pair.key_pair_key_name}.pem"
  file_permission = "0600"
}

module "vpc" {
  source                               = "./modules/vpc"
  region                               = var.region
  for_each                             = var.spoke
  name                                 = each.key
  create_igw                           = each.value.nat_gw == true ? true : false
  enable_nat_gateway                   = each.value.nat_gw == true ? true : false
  cidr_block                           = each.value.cidr_block
  manage_default_route_table           = true
  map_public_ip_on_launch              = false
  single_nat_gateway                   = true
  enable_dns_hostnames                 = true
  enable_dns_support                   = true
  manage_default_security_group        = false
  enable_flow_log                      = false
  create_flow_log_cloudwatch_log_group = false
  create_flow_log_cloudwatch_iam_role  = false
  flow_log_max_aggregation_interval    = 60
  transit_gateway_id                   = module.tgw.tgw_id
  vpc_security_groups                  = local.vpc_security_groups
}


# AWS Transit Gateway Deployment
module "tgw" {
  source                                         = "./modules/tgw"
  default_route_table_association                = "disable"
  default_route_table_propagation                = "disable"
  dns_support                                    = "enable"
  inspection_vpc_id                              = local.inspection_vpcs[0]
  inspection_vpc_attachment_subnets              = values({ for k, v in module.vpc : k => v.intra_subnets if contains(local.inspection_vpcs, k) })[0]
  spoke_vpc_map                                  = local.spoke_vpc_intra_map
  spoke_transit_gateway_default_route_attachment = values(module.inspection_vpc)
  inspection_vpc_attachment                      = values(module.inspection_vpc)[0].inspection_vpc_attachment
  spoke_vpc_attachments                          = { for k, v in module.spoke_vpc : k => v.spoke_vpc_attachment }
}


# The IAM role creates the nessesary policies for the EC2 instance
module "iam_roles" {
  source = "./modules/iam_roles"
}

#  The Compute module deployes EC2 instances into Spoke VPCs only, the number of instnaces are defined in variables.tf
module "compute" {
  source                      = "./modules/compute"
  for_each                    = { for k, v in module.vpc : k => v if contains(local.spoke_vpcs, k) }
  vpc_id                      = each.value.vpc_id
  instance_count              = var.spoke[each.key].instances_per_subnet
  name                        = "${each.key}-instance"
  instance_type               = var.spoke[each.key].instance_type
  cpu_credits                 = "standard"
  subnet_id                   = var.ec2_multi_subnet ? each.value.private_subnets : slice(each.value.private_subnets, 0, 1)
  associate_public_ip_address = false
  key_name                    = module.key_pair.key_pair_key_name
  instance_security_groups    = local.instance_security_groups
  iam_instance_profile        = module.iam_roles.terraform_ssm_iam_role.name
}

# The VPC Endpoint module deploys the necessary AWS VPC Endpoints to allow SSM
# VPC Endpoints are only deployed into Spoke VPCs
module "vpc_endpoints" {
  source = "./modules/endpoints"

  # Only create VPC endpoints for spoke VPCs
  for_each = {
    for k, v in module.vpc : k => v if length((regexall("spoke", k))) > 0
  }
  subnet_ids               = each.value.private_subnets
  vpc_id                   = each.value.vpc_id
  endpoint_security_groups = local.endpoint_security_groups
}

# Module to configre Spoke VPC routing
module "spoke_vpc" {
  source                                          = "./modules/spoke_vpc"
  for_each                                        = { for k, v in module.vpc : k => v if contains(local.spoke_vpcs, k) }
  name                                            = each.key
  vpc_id                                          = each.value.vpc_id
  transit_gateway_id                              = module.tgw.tgw_id
  transit_gateway_attach_subnets                  = each.value.intra_subnets
  transit_gateway_default_route_table_association = false
  intra_route_table_id                            = each.value.intra_route_tables
  public_route_table_id                           = each.value.public_route_tables
  private_route_table_id                          = each.value.private_route_tables
  spoke_transit_gateway_route_table_id            = module.tgw.spoke_transit_gateway_route_table_id
  depends_on = [
    module.tgw.tgw_id
  ]
}

# Module to configre Inspection VPC routing
module "inspection_vpc" {
  source                                          = "./modules/inspection_vpc"
  for_each                                        = { for k, v in module.vpc : k => v if contains(local.inspection_vpcs, k) }
  name                                            = each.key
  vpc_id                                          = each.value.vpc_id
  transit_gateway_id                              = module.tgw.tgw_id
  transit_gateway_attach_subnets                  = each.value.intra_subnets
  transit_gateway_default_route_table_association = false
  spoke_transit_gateway_route_table_id            = module.tgw.inspection_transit_gateway_route_table_id
  spoke_route_table_ids                           = each.value.intra_route_tables
  spoke_vpc_cidr_blocks                           = local.spoke_cidr
  anfw_endpoint_info                              = module.aws_network_firewall.anfw
  intra_route_table_id                            = each.value.intra_route_tables
  public_route_table_id                           = each.value.public_route_tables
  private_route_table_id                          = each.value.private_route_tables
}

/* Module to the AWS Network Firewall
   The ANFW policy is defined in the policy.tf file in the aws_network_firewall module directory */
module "aws_network_firewall" {
  source                          = "./modules/network_firewall"
  region                          = var.region
  identifier                      = var.project_name
  inspection_vpc_id               = values({ for k, v in module.vpc : k => v.vpc_id if contains(local.inspection_vpcs, k) })[0]
  inspection_vpc_firewall_subnets = values({ for k, v in module.vpc : k => v.private_subnets if contains(local.inspection_vpcs, k) })[0]
  spoke_cidr_blocks               = [for i in var.spoke : i.cidr_block if i.spoke == true]


}
