// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "vpc" {
  description = "The ID of the VPC"
  value       = [for i in module.vpc : i]
}

output "tgw" {
  description = "TGW ID"
  value       = [for i in module.tgw : i]
}

output "compute" {
  description = "Compute Module Output"
  value       = [for i in module.compute : i]
}

output "spoke_routes" {
  description = "Spoke Route Module Output"
  value       = [for i in module.spoke_vpc : i]
}

output "inspection_routes" {
  description = "Inspection Route Module Output"
  value       = [for i in module.inspection_vpc : i]
}


output "firewall" {
  value = { for k, v in module.vpc : k => v if contains(local.inspection_vpcs, k) }
}

output "anfw_output" {
  value = module.aws_network_firewall.anfw
}

output "terraform_iam_role" {
  value = module.iam_roles.terraform_ssm_iam_role
}
