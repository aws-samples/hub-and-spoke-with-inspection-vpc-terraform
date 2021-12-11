// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

# Create an AWS Network Firewall instance
resource "aws_networkfirewall_firewall" "inspection_vpc_network_firewall" {
  name                = "NetworkFirewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.anfw_policy.arn
  vpc_id              = var.inspection_vpc_id

  dynamic "subnet_mapping" {
    for_each = var.inspection_vpc_firewall_subnets

    content {
      subnet_id = subnet_mapping.value
    }
  }

}
# Create a Cloudwatch Log Group for AWS Network Firewall Alerts
resource "aws_cloudwatch_log_group" "network_firewall_alert_log_group" {
  name = "/aws/network-firewall/alerts"
}

# Create a Cloudwatch Log Group for AWS Network Firewall Flows
resource "aws_cloudwatch_log_group" "network_firewall_flow_log_group" {
  name = "/aws/network-firewall/flows"
}

# Confiture AWS Network Firewall logging
resource "aws_networkfirewall_logging_configuration" "network_firewall_alert_logging_configuration" {
  firewall_arn = aws_networkfirewall_firewall.inspection_vpc_network_firewall.arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.network_firewall_alert_log_group.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.network_firewall_flow_log_group.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    }
  }
}
