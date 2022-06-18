/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
   SPDX-License-Identifier: MIT-0 */

locals {
  log_destination = {
    alert = {
      cloud-watch-logs = {
        logGroup = var.logging_config == "cloud-watch-logs" ? aws_cloudwatch_log_group.anfwlogs_lg_alert[0].id : ""
      }
      s3 = {
        bucketName = var.logging_config == "s3" ? aws_s3_bucket.s3_bucket[0].bucket : ""
        prefix     = "/alert"
      }
      kinesis-firehose = {
        deliveryStream = ""
      }
    }
    flow = {
      cloud-watch-logs = {
        logGroup = var.logging_config == "cloud-watch-logs" ? aws_cloudwatch_log_group.anfwlogs_lg_alert[0].id : ""
      }
      s3 = {
        bucketName = var.logging_config == "s3" ? aws_s3_bucket.s3_bucket[0].bucket : ""
        prefix     = "/flow"
      }
      kinesis-firehose = {
        deliveryStream = ""
      }
    }
  }

  log_destination_type = {
    cloud-watch-logs = "CloudWatchLogs"
    s3               = "S3"
    kinesis-firehose = "KinesisDataFirehose"
  }

  availability_zones = keys({ for k, v in var.vpc_info.private_subnet_attributes_by_az : k => v })
}