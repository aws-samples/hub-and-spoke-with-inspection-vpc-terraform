/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

# Variables that define project configuration
variable "region" {
  description = "AWS Region"
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "aws-hub-and-spoke-demo"
}

variable "ec2_multi_subnet" {
  description = "Multi subnet Instance Deployment"
  type        = bool
  default     = false
}


# Spoke variables
variable "spoke" {
  description = "VPC Spokes"
  type        = map(any)
  default = {
    "inspection-vpc" = {
      cidr_block           = "10.129.0.0/16",
      instances_per_subnet = 1,
      instance_type        = "t2.micro",
      spoke                = false
      nat_gw               = true
    }
    "spoke-vpc-1" = {
      cidr_block           = "10.11.0.0/16",
      instances_per_subnet = 1,
      instance_type        = "t2.micro",
      spoke                = true
      nat_gw               = false
    }
    "spoke-vpc-2" = {
      cidr_block           = "10.12.0.0/16",
      instances_per_subnet = 1,
      instance_type        = "t2.micro",
      spoke                = true
      nat_gw               = false
    }
  }
}
variable "my_ip" {
description = "Local ip for testing"
  type        = string
}
