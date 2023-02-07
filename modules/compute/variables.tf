/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

variable "project_name" {
  type        = string
  description = "Project identifier."
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC where the EC2 instance(s) are created."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to create the instances."
}

variable "vpc_subnets" {
  type        = list(string)
  description = "Subnets in the VPC to create the instances."
}

variable "number_azs" {
  type        = number
  description = "Number of AZs to place instances."
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type."
}

variable "ami_id" {
  type        = string
  description = "AMI ID."
}

variable "ec2_iam_instance_profile" {
  type        = string
  description = "EC2 instance profile to attach to the EC2 instance(s)"
}

variable "ec2_security_group" {
  type        = string
  description = "Information about the Security Groups to create."
}
