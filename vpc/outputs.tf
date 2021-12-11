// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  # value       = module.vpc.vpc_id[*]
  value = module.vpc.vpc_id
}

output "default_route_table_id" {
  value = module.vpc.default_route_table_id
}

# Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets[*]
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets[*]
}

output "intra_subnets" {
  description = "List of IDs of intra subnets"
  value       = module.vpc.intra_subnets[*]
}

output "intra_route_tables" {
  description = "List of IDs of intra subnets"
  value       = module.vpc.intra_route_table_ids[0]
}

output "private_route_tables" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_route_table_ids[0]
}

output "public_route_tables" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_route_table_ids[0]
}

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = module.vpc.igw_id
}
