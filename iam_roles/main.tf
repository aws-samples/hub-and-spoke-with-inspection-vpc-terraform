// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

#Instance Role
resource "aws_iam_role" "terraform_iam_role" {
  name               = "test-ssm-ec2"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name        = "terraform-ssm-ec2-role"
    createdBy   = "taylaand"
    Owner       = "Terraform"
    Project     = "terraform-hub-and-spoke"
    environment = "test"
  }
}

#Instance Profile
resource "aws_iam_instance_profile" "terraform_ssm_instance_profile" {
  name = "terraform-ssm-ec2"
  role = aws_iam_role.terraform_iam_role.id
}

#Attach Policies to Instance Role
resource "aws_iam_policy_attachment" "terraform_ssm_iam_role_polcy_attachment" {
  name       = "terraform_ssm_iam_role_polcy_attachment"
  roles      = [aws_iam_role.terraform_iam_role.id]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "terraform_ssm_iam_service_role_attachment" {
  name       = "terraform_ssm_iam_service_role_attachment"
  roles      = [aws_iam_role.terraform_iam_role.id]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
