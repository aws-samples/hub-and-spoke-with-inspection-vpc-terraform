/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

locals {
  availability_zones = keys({ for k, v in var.vpc_info.private_subnet_attributes_by_az : k => v })
}