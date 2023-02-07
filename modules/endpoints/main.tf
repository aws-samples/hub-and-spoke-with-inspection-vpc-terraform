/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

# Deploy SSM, SMM Messages, EC2 and EC2 Messages VPC Endpoints
# This provides SSM Connectivity to EC2 Compute Instances

# VPC ENDPOINTS
resource "aws_vpc_endpoint" "endpoint" {
  for_each = var.endpoints_service_names

  vpc_id              = var.vpc_id
  service_name        = each.value.name
  vpc_endpoint_type   = each.value.type
  subnet_ids          = var.vpc_subnets
  security_group_ids  = [var.endpoints_security_group]
  private_dns_enabled = each.value.private_dns
}
