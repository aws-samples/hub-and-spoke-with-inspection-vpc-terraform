# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- examples/central_shared_services/modules/compute/outputs.tf ---

output "ec2_instances" {
  value       = aws_instance.ec2_instance
  description = "List of instances created."
}

output "endpoint_ids" {
  value       = { for k, v in aws_vpc_endpoint.endpoint : k => v.id }
  description = "VPC Endpoints information."
}