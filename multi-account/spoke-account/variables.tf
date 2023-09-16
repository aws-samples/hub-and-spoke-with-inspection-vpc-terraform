/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- spoke-account/variables.tf ---

variable "identifier" {
  type        = string
  description = "Account Identifier."

  default = "spoke-account"
}

variable "aws_region" {
  type        = string
  description = "AWS Region."

  default = "eu-west-1"
}

variable "secrets_names" {
  type        = map(string)
  description = "AWS Secrets Manager secrets name."

  default = {
    networking_account_tgw         = "networking-account-transit-gateway-id"
    networking_account_ipam        = "networking-account-ipam-pool-id"
    networking_account_attachments = "network-account-vpc-attachments"
  }
}

variable "vpcs" {
  type        = any
  description = "VPC information."
  default = {
    vpc1 = {
      routing_domain = "prod"
      number_azs     = 2
      instance_type  = "t3.micro"
    }
    vpc2 = {
      routing_domain = "nonprod"
      number_azs     = 2
      instance_type  = "t3.micro"
    }
  }
}

variable "networking_account" {
  type        = string
  description = "Networking Account ID."
}