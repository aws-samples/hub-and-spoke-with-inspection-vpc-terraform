/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

locals {
  firewall_vpc_endpoint_descriptions = [for ss in tolist(var.anfw_endpoint_info.firewall_status[0].sync_states) : "${ss.attachment[0].endpoint_id}"]
}
