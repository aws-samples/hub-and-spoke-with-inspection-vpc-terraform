/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

output "endpoint_ids" {
  value       = { for k, v in aws_vpc_endpoint.endpoint: k => v.id }
  description = "VPC Endpoints information."
}