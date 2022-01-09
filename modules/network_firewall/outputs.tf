/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

output "anfw" {
  description = "AWS Network Firewall Output"
  value = aws_networkfirewall_firewall.inspection_vpc_network_firewall
}
