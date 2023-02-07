/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

# Variables that define project configuration
variable "region" {
  description = "AWS Region."
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Name of the project."
  type        = string
  default     = "hubspoke-inspection"
}

# Spoke VPCs
variable "spoke_vpcs" {
  description = "Spoke VPCs definition."
  type        = any

  default = {
    "spoke-vpc-1" = {
      cidr_block              = "10.0.0.0/24"
      workload_subnet_netmask = 28
      endpoint_subnet_netmask = 28
      tgw_subnet_netmask      = 28
      number_azs              = 2
      instance_type           = "t2.micro"

      flow_log_config = {
        log_destination_type = "cloud-watch-logs"
        retention_in_days    = 7
      }
    }

    "spoke-vpc-2" = {
      cidr_block              = "10.0.1.0/24"
      workload_subnet_netmask = 28
      endpoint_subnet_netmask = 28
      tgw_subnet_netmask      = 28
      number_azs              = 2
      instance_type           = "t2.micro"

      flow_log_config = {
        log_destination_type = "cloud-watch-logs"
        retention_in_days    = 7
      }
    }
  }
}

# Inspection VPC
variable "inspection_vpc" {
  description = "Inspection VPC definition."
  type        = any

  default = {
    cidr_block             = "10.129.0.0/24"
    public_subnet_netmask  = 28
    private_subnet_netmask = 28
    tgw_subnet_netmask     = 28
    number_azs             = 2
  }
}