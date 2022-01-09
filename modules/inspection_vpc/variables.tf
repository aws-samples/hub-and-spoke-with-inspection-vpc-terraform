/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

variable "transit_gateway_id" {
  type        = string
  description = "Transit Gateway ID"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "transit_gateway_attach_subnets" {
  type        = list(string)
  description = "List of TGW Attachment Subnet IDs"
}

variable "transit_gateway_default_route_table_association" {
  type        = string
  description = "Transit Gateway Default Route Table Association ID"
  default     = "false"
}

variable "transit_gateway_default_route_table_propagation" {
  type        = string
  description = "Transit Gateway Default Route Table Propogation"
  default     = "false"
}

variable "name" {
  type        = string
  description = "Name of the spoke VPC"

}

variable "spoke_transit_gateway_route_table_id" {
  type        = string
  description = "Spoke Route Table ID"
}

variable "spoke_vpc_cidr_blocks" {
  type        = list(string)
  description = "List of Spoke VPC CIDR Blocks"
}

variable "spoke_route_table_ids" {
  type = string
  description = "value of the spoke route table ids"
}

variable "anfw_endpoint_info" {
  description = "values for ANFW endpoint"
  type        = any
}


variable "intra_route_table_id" {
  type = string
  description = "values for intra VPC route table"
}


variable "private_route_table_id" {
  type = string
  description = "values for private VPC route table"

}

variable "public_route_table_id" {
  type = string
  description = "values for public VPC route table"
}
