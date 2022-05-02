/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

variable "region" {
  type        = string
  description = "AWS Region"
  default     = ""
}

variable "name" {
  type        = string
  description = "Name of the VPC"
  default     = ""
}

variable "create_igw" {
  type        = bool
  description = "Create a VPC IGW"
  default     = true
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Enable NAT Gateway"
  default     = true
}

variable "single_nat_gateway" {
  type        = bool
  description = "Deploy a Single NAT Gateway"
  default     = true

}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS Hostname Support"
  default     = true
}

variable "enable_dns_support" {
  type        = bool
  description = "Enable DNS Support"
  default     = true
}

variable "cidr_block" {
  type        = string
  description = "AWS Region"
  default     = "10.0.0.0/16"
}

variable "private_subnet_suffix" {
  type        = string
  description = "Private Subnet Prefix"
  default     = "private-subnet"
}

variable "public_subnet_suffix" {
  type        = string
  description = "Public Subnet Prefix"
  default     = "public-subnet"
}

variable "intra_subnet_suffix" {
  type        = string
  description = "Internal Subnet Prefix"
  default     = "intra-subnet"
}

variable "manage_default_security_group" {
  type        = bool
  description = "Manage Default Security Group"
  default     = true
}

variable "enable_flow_log" {
  type        = bool
  description = "Enable Flow Logs"
  default     = false
}

variable "create_flow_log_cloudwatch_log_group" {
  type        = bool
  description = "Create Flow Log CloudWatch Log Group"
  default     = false
}

variable "create_flow_log_cloudwatch_iam_role" {
  type        = bool
  description = "Create Flow Log CloudWatch IAM Role"
  default     = false
}

variable "flow_log_max_aggregation_interval" {
  type        = number
  description = "Flow Log Max Aggregation Intervial"
  default     = 60
}

variable "manage_default_route_table" {
  type        = bool
  description = "Manage the default table"
  default     = false
}

variable "transit_gateway_id" {
  type        = string
  description = "Transit Gateway ID"
  default     = ""
}

variable "tgw" {
  type        = string
  description = "Transit Gateway ID"
  default     = ""
}

variable "vpc_security_groups" {
  type = any
  description = "VPC Security Groups created"
}

variable "map_public_ip_on_launch" {
  type        = bool
  description = "Map Public IP on Launch"
  default     = false
}
