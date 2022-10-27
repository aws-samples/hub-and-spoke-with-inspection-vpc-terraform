/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.73.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 0.15.0"
    }
  }
}

# AWS Provider configuration - AWS Region indicated in root/variables.tf
provider "aws" {
  region = var.region
}
provider "awscc" {
  region = var.region
}



