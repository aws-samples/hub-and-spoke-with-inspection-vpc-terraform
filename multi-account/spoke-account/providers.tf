/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- spoke-account/providers.tf ---

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.16.2"
    }
  }
}

# Provider definition for Spoke AWS Account
provider "aws" {
  region = var.aws_region
}