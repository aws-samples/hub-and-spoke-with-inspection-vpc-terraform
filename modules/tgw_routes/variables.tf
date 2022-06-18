/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

variable "transit_gateway_id" {
  type        = string
  description = "Transit Gateway ID."
}

variable "tgw_spoke_attachments" {
  type        = map(string)
  description = "List of TGW Attachments of all the Spokes VPCs."
}

variable "tgw_inspection_attachment" {
  type        = string
  description = "TGW Attachment of the Inspection VPC"
}