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

variable "supernet" {
  type        = string
  description = "Network's supernet - used for the routes to the Firewall Endpoint from the public subnet."
}

variable "transit_gateway_id" {
  type        = string
  description = "Transit Gateway ID - to use in the VPC routes from the ANFW endpoints."
}

variable "number_azs" {
  type        = number
  description = "Number of Availability Zones, indicated in the root variables."
}

variable "logging_config" {
  type        = string
  description = "Logging configuration (defined in root variables)."
}

variable "kms_key" {
  type        = string
  description = "ARN of KMS Key to use in the logs encryption (at rest)."
}
