// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

variable "inspection_vpc_id" {
  type        = string
  description = "Inspection VPC ID"
}


variable "inspection_vpc_firewall_subnets" {
  type        = list(string)
  description = "Inspection VPC Firewall Subnets"
}

variable "spoke_cidr_blocks" {
  description = "Spoke CIDR blocks"
}
