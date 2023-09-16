# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- multi-account/modules/iam/outputs.tf ---

output "ec2_iam_instance_profile" {
  value       = aws_iam_instance_profile.ec2_instance_profile.id
  description = "EC2 instance profile to use in the EC2 instace(s) to create."
}