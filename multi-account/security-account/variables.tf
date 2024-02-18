/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- security-account/variables.tf ---

variable "identifier" {
  type        = string
  description = "Account Identifier."

  default = "security-account"
}

variable "aws_region" {
  type        = string
  description = "AWS Region."

  default = "eu-west-1"
}

variable "network_supernet" {
  type        = string
  description = "Network supernet."

  default = "10.0.0.0/16"
}

variable "secret_name" {
  type        = string
  description = "AWS Secrets Manager secret name."

  default = "security-account-firewall-policy-arn"
}