/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets to deploy VPC Endponts"
}

variable "endpoint_security_groups" {
  type        = any
  description = "Security Group for Endpoints"
}
