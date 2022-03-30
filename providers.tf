/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */



terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">=3.71.0"
    }
    tls = ">= 3.0.0"
    random = ">= 3.0.0"
    local = ">= 2.0.0"
    external = ">= 2.0.0"
  }
}


# The region is defined in the root/variables.tf file.
provider "aws" {
  region = var.region
}




