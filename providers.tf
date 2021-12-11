// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# The region is defined in the root/variables.tf file.
provider "aws" {
  region = var.region
}