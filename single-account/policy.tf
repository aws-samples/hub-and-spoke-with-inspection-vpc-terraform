/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

# --- single-account/policy.tf ---

resource "aws_networkfirewall_firewall_policy" "anfw_policy" {
  name = "firewall-policy-${var.identifier}"

  firewall_policy {
    # Stateless configuration
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateless_rule_group_reference {
      priority     = 10
      resource_arn = aws_networkfirewall_rule_group.drop_remote.arn
    }

    # Stateful configuration
    stateful_engine_options {
      rule_order = "STRICT_ORDER"
    }
    stateful_default_actions = ["aws:drop_strict", "aws:alert_strict"]
    stateful_rule_group_reference {
      priority     = 10
      resource_arn = aws_networkfirewall_rule_group.allow_icmp.arn
    }
    stateful_rule_group_reference {
      priority     = 20
      resource_arn = aws_networkfirewall_rule_group.allow_tcp.arn
    }
    stateful_rule_group_reference {
      priority     = 30
      resource_arn = aws_networkfirewall_rule_group.allow_domains.arn
    }
  }
}

# Stateless Rule Group - Dropping any SSH connection
resource "aws_networkfirewall_rule_group" "drop_remote" {
  capacity = 2
  name     = "drop-remote-${var.identifier}"
  type     = "STATELESS"
  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {

        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:drop"]
            match_attributes {
              protocols = [6]
              source {
                address_definition = "0.0.0.0/0"
              }
              source_port {
                from_port = 22
                to_port   = 22
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
              destination_port {
                from_port = 22
                to_port   = 22
              }
            }
          }
        }
      }
    }
  }
}

# Stateful Rule Group 1 - Allowing ICMP traffic
resource "aws_networkfirewall_rule_group" "allow_icmp" {
  capacity = 1
  name     = "allow-icmp-${var.identifier}"
  type     = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "SUPERNET"
        ip_set {
          definition = ["10.0.0.0/16"]
        }
      }
    }
    rules_source {
      rules_string = <<EOF
      pass icmp $SUPERNET any -> $SUPERNET any (msg: "Allowing ICMP packets"; sid:2; rev:1;)
      EOF
    }
    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }
  }
}

# Stateful Rule Group 2 - Allowing TCP traffic to port 443 (HTTS) access to .amazon.com (HTTPS)
resource "aws_networkfirewall_rule_group" "allow_tcp" {
  capacity = 1
  name     = "allow-tcp-${var.identifier}"
  type     = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "VPCS"
        ip_set {
          definition = values({for k, v in var.spoke_vpcs: k => v.cidr_block })
        }
      }
    }
    rules_source {
      rules_string = <<EOF
      pass tcp $VPCS any <> $EXTERNAL_NET 443 (msg:"Allowing TCP in port 443"; flow:not_established; sid:892123; rev:1;)
      EOF
    }
    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }
  }
}

# Stateful Rule Group 3 - Allowing access to .amazon.com (HTTPS)
resource "aws_networkfirewall_rule_group" "allow_domains" {
  capacity = 100
  name     = "allow-domains-${var.identifier}"
  type     = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = values({ for k, v in var.spoke_vpcs: k => v.cidr_block })
        }
      }
    }
    rules_source {
      rules_source_list {
        generated_rules_type = "ALLOWLIST"
        target_types         = ["TLS_SNI"]
        targets              = [".amazon.com"]
      }
    }
    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }
  }
}