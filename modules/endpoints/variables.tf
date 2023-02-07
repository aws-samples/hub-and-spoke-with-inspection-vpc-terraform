/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

variable "project_name" {
  description = "Project identifier."
  type        = string
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC where the VPC endpoints are created."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to create the endpoint(s)."
}

variable "vpc_subnets" {
  type        = list(string)
  description = "List of the subnets to place the endpoint(s)."
}

variable "endpoints_security_group" {
  type        = string
  description = "Information about the Security Groups to create - for the VPC endpoints."
}

variable "endpoints_service_names" {
  type        = any
  description = "Information about the VPC endpoints to create."
}
