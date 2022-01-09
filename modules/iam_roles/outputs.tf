/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

output "terraform_ssm_iam_role" {
  value = aws_iam_instance_profile.terraform_ssm_instance_profile
  description = "SSM IAM Role"
}
