// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

locals {
  spoke_cidr              = [for i in var.spoke : i.cidr_block if i.spoke == true]
  inspection_vpcs         = [for i in keys(var.spoke) : i if var.spoke[i].spoke == false]
  spoke_vpcs              = [for i in keys(var.spoke) : i if var.spoke[i].spoke == true]
  spoke_vpc_ids           = { for k, v in module.vpc : k => v.vpc_id if contains(local.spoke_vpcs, k) }
  spoke_vpc_intra_subnets = { for k, v in module.vpc : k => v.intra_subnets if contains(local.spoke_vpcs, k) }
  spoke_vpc_intra_map     = zipmap(values(local.spoke_vpc_ids), values(local.spoke_vpc_intra_subnets))

  vpc_security_groups = {
    public = {
      name        = "public_vpc_security_group"
      description = "ingress access"
      ingress = {
        open = {
          from        = 0
          to          = 0
          protocol    = -1
          cidr_blocks = [var.my_ip]
        }
        ssh = {
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
        http = {
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }

  instance_security_groups = {
    public = {
      name        = "public_instance_security_group"
      description = "ingress access"
      ingress = {
        open = {
          from        = 0
          to          = 0
          protocol    = -1
          cidr_blocks = [var.my_ip]
        }
        ssh = {
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
        http = {
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }

  endpoint_security_groups = {
    public = {
      name        = "endoint_security_group"
      description = "ingress access"
      ingress = {
        open = {
          from        = 0
          to          = 0
          protocol    = -1
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }
}
