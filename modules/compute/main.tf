/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

# EC2 instances
resource "aws_instance" "ec2_instance" {
  count = var.number_azs

  ami                         = var.ami_id
  associate_public_ip_address = false
  instance_type               = var.instance_type
  vpc_security_group_ids      = [var.ec2_security_group]
  subnet_id                   = var.vpc_subnets[count.index]
  iam_instance_profile        = var.ec2_iam_instance_profile

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "${var.vpc_name}-instance-${count.index + 1}-${var.project_name}"
  }
}