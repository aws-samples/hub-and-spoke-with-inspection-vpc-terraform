/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- networking-account/variables.tf ---

variable "identifier" {
  type        = string
  description = "Account Identifier."

  default = "networking-account"
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
    security_account               = "security-account-firewall-policy-arn"
    networking_account_tgw         = "networking-account-transit-gateway-id"
    networking_account_ipam        = "networking-account-ipam-pool-id"
    networking_account_attachments = "network-account-vpc-attachments"
  }
}

variable "security_account" {
  type        = string
  description = "Security Account ID."
}