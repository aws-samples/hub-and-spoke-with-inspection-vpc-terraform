/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_nat_gateway" "nat_gw" {
  vpc_id = var.vpc_id
}

data "aws_internet_gateway" "inspection_igw" {
  filter {
    name   = "attachment.vpc-id"
    values = ["${var.vpc_id}"]
  }
}
