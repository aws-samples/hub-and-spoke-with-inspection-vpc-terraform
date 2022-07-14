/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

# Variables that define project configuration
variable "region" {
  description = "AWS Region."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project."
  type        = string
  default     = "aws-hub-and-spoke-demo"
}

variable "ec2_multi_subnet" {
  description = "Multi subnet Instance Deployment."
  type        = bool
  default     = true
}

variable "supernet" {
  description = "Hub and Spoke Supernet."
  type        = string
  default     = "10.0.0.0/8"
}

# Spoke VPCs
variable "spoke_vpcs" {
  description = "Spoke VPCs definition."
  type        = any

  default = {
    "spoke-vpc-1" = {
      cidr_block             = "10.0.0.0/16"
      private_subnet_netmask = 28
      tgw_subnet_netmask     = 28
      number_azs             = 2
      instance_type          = "t2.micro"

      flow_log_config = {
        log_destination_type = "cloud-watch-logs"
        retention_in_days    = 7
      }
    }

    "spoke-vpc-2" = {
      cidr_block             = "10.1.0.0/16"
      private_subnet_netmask = 24
      tgw_subnet_netmask     = 28
      number_azs             = 2
      instance_type          = "t2.micro"

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

    flow_log_config = {
      log_destination_type = "cloud-watch-logs"
      retention_in_days    = 7
    }
  }
}