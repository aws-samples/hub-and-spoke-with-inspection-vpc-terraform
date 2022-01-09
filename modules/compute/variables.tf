/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "instance_count" {
  type        = string
  description = "Number of EC2 Instances"
  default     = 1
}

variable "name" {
  type        = string
  description = "EC2 Instance Name"
  default     = "Compute"
}

variable "instance_type" {
  type        = string
  description = "EC2 Instance Type"
  default     = "t2.micro"
}

variable "cpu_credits" {
  type        = string
  description = "T type CPU Credits"
  default     = "standard"
}

variable "subnet_id" {
  type        = list(any)
  description = "Subnet ID to deploy into"
  default     = []
}

variable "associate_public_ip_address" {
  type        = bool
  description = "Associate Public IP Addresses"
  default     = false
}

variable "key_name" {
  description = "value of ssh key_name"
  type        = string
  default     = ""
}

variable "instance_security_groups" {
  type = any
  description = "value of instance security groups"
}

variable "iam_instance_profile" {
  type = string
  description = "value of iam instance profile"
}
