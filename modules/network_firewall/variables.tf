/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

variable "project_name" {
  type        = string
  description = "Project identifier."
}

variable "vpc_name" {
  type        = string
  description = "VPC name."
}

variable "vpc_info" {
  type        = any
  description = "VPC Information."
}

variable "policy_document" {
  type        = string
  description = "Policy document."
}

variable "supernet" {
  type        = string
  description = "Network's supernet - used for the routes to the Firewall Endpoint from the public subnet."
}

variable "number_azs" {
  type        = number
  description = "Number of Availability Zones, indicated in the root variables."
}
