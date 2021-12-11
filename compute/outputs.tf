// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "ec2_id" {
  value = module.ec2_with_t2_unlimited[*].id
}

output "security_group_ids" {
  value = [for i in aws_security_group.instance_security_group : i.id]
}
