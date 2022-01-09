/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

variable "region" {
  type = string
  description = "Value for AWS region"
}
variable "inspection_vpc_id" {
  type        = string
  description = "Inspection VPC ID"
}


variable "inspection_vpc_firewall_subnets" {
  type        = list(string)
  description = "Inspection VPC Firewall Subnets"
}

variable "spoke_cidr_blocks" {
  type = list(string)
  description = "Spoke CIDR blocks"
}

variable "identifier" {
  type = string
  description = "Identifier for the kms key"
}
