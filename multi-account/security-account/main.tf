/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- security-account/main.tf ---

# ---------- AWS ORGANIZATIONS AND ACCOUNT INFORMATION ----------
data "aws_caller_identity" "aws_security_account" {}
data "aws_organizations_organization" "org" {}

# ---------- NETWORK FIREWALL POLICY ----------
# Firewall policy
resource "aws_networkfirewall_firewall_policy" "central_inspection_policy" {
  name = "central-firewall-policy-${var.identifier}"

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
      resource_arn = aws_networkfirewall_rule_group.allow_tcp.arn
    }
    stateful_rule_group_reference {
      priority     = 20
      resource_arn = aws_networkfirewall_rule_group.allow_domains.arn
    }
  }
}

# Stateless Rule Group - Dropping SSH traffic
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
                from_port = 0
                to_port   = 65535
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

# Stateful Rule Group - Allowing TCP traffic to port 443 (HTTPS)
resource "aws_networkfirewall_rule_group" "allow_tcp" {
  capacity = 1
  name     = "allow-tcp-${var.identifier}"
  type     = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "NETWORK"
        ip_set {
          definition = [var.network_supernet]
        }
      }
    }
    rules_source {
      rules_string = <<EOF
      pass tcp $NETWORK any <> $EXTERNAL_NET 443 (msg:"Allowing TCP in port 443"; flow:not_established; sid:892123; rev:1;)
      EOF
    }
    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }
  }
}


# Stateful Rule Group - Allowing access to .amazon.com (HTTPS)
resource "aws_networkfirewall_rule_group" "allow_domains" {
  capacity = 100
  name     = "allow-domains-${var.identifier}"
  type     = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = [var.network_supernet]
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

# ---------- AWS RAM SHARE ----------
# Resource Share
resource "aws_ram_resource_share" "resource_share" {
  name                      = "Security Account Resource Share"
  allow_external_principals = false
}

# Principal Association
resource "aws_ram_principal_association" "principal_association" {
  principal          = data.aws_organizations_organization.org.arn
  resource_share_arn = aws_ram_resource_share.resource_share.arn
}

# Resource Association - AWS Transit Gateway
resource "aws_ram_resource_association" "firewall_policy_share" {
  resource_arn       = aws_networkfirewall_firewall_policy.central_inspection_policy.arn
  resource_share_arn = aws_ram_resource_share.resource_share.arn
}

# ---------- AWS SECRETS MANAGER ----------
# Firewall Policy ARN Secret
resource "aws_secretsmanager_secret" "firewall_policy_arn" {
  name                    = var.secret_name
  description             = "Firewall Policy ARN (Security Account)."
  kms_key_id              = aws_kms_key.secrets_key.arn
  policy                  = data.aws_iam_policy_document.secrets_resource_policy.json
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "firewall_policy_arn" {
  secret_id     = aws_secretsmanager_secret.firewall_policy_arn.id
  secret_string = aws_networkfirewall_firewall_policy.central_inspection_policy.arn
}

# Secrets resource policy - Allowing the AWS Organization to read the secret
data "aws_iam_policy_document" "secrets_resource_policy" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetResourcePolicy"
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"

      values = ["${data.aws_organizations_organization.org.id}"]
    }
  }
}

# KMS Key to encrypt the secrets
resource "aws_kms_key" "secrets_key" {
  description             = "KMS Secrets Key - Security Account."
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.policy_kms_document.json

  tags = {
    Name = "kms-key-${var.identifier}"
  }
}

# KMS Policy
data "aws_iam_policy_document" "policy_kms_document" {
  statement {
    sid    = "Enable AWS Secrets Manager secrets decryption."
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:*"
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"

      values = ["secretsmanager.${var.aws_region}.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:SecretARN"

      values = ["arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.aws_security_account.id}:secret:*"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"

      values = ["${data.aws_organizations_organization.org.id}"]
    }
  }

  statement {
    sid       = "Enable IAM User Permissions"
    actions   = ["kms:*"]
    resources = ["arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.aws_security_account.id}:*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.aws_security_account.id}:root"]
    }
  }
}
