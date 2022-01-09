/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */
   
output "spoke_vpc_attachment_rt_association" {
  # value = aws_ec2_transit_gateway_route_table_association.spoke_vpc_attachment_rt_association.id
  value = flatten([for i in aws_ec2_transit_gateway_route_table_association.spoke_vpc_attachment_rt_association : i])
}

output "spoke_vpc_attachment" {
  value = aws_ec2_transit_gateway_vpc_attachment.spoke_vpc_attachment.id
}
