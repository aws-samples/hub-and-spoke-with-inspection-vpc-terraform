// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

output "inspection_vpc_attachment" {
  value = aws_ec2_transit_gateway_vpc_attachment.inspection_vpc_attachment.id
}
