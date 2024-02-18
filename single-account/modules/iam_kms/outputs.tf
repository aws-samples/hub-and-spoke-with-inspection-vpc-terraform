# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- single-account/modules/iam_kms/outputs.tf ---

output "vpc_flowlogs_role" {
  value       = aws_iam_role.vpc_flowlogs_role.id
  description = "VPC Flow Logs IAM Role."
}

output "kms_key" {
  value       = aws_kms_key.log_key.arn
  description = "KMS Key - to encrypt VPC Flow Logs."
}