/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

output "endpoints" {
  value = module.vpc_endpoints.endpoints
  description = "value of vpc_endpoints.endpoints"
}