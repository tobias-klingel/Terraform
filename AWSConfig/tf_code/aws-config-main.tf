provider "aws" {
  region  = var.region
}


#################################################################################################
#IAM for Config
####################
resource "aws_iam_role" "config" {
  name = "config-${var.region}"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "config" {
  role       = "${aws_iam_role.config.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}

#################################################################################################
#Config S3 bucket
####################

resource "aws_s3_bucket" "config" {
  bucket_prefix = var.bucket_prefix
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false
  }

  lifecycle_rule {
    enabled = true
    prefix  = "${var.bucket_key_prefix}/"

    expiration {
      days = 365
    }

    noncurrent_version_expiration {
      days = 365
    }
  }

}


resource "aws_s3_bucket_policy" "config_bucket_policy" {
  bucket = "${aws_s3_bucket.config.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Allow bucket ACL check",
      "Effect": "Allow",
      "Principal": {
        "Service": [
         "config.amazonaws.com"
        ]
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "${aws_s3_bucket.config.arn}",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "true"
        }
      }
    },
    {
      "Sid": "Allow bucket write",
      "Effect": "Allow",
      "Principal": {
        "Service": [
         "config.amazonaws.com"
        ]
      },
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.config.arn}/${var.bucket_key_prefix}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        },
        "Bool": {
          "aws:SecureTransport": "true"
        }
      }
    },
    {
      "Sid": "Require SSL",
      "Effect": "Deny",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:*",
      "Resource": "${aws_s3_bucket.config.arn}/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
POLICY
}

#################################################################################################
#Config
####################


#Config Configuration Recorder
resource "aws_config_configuration_recorder" "config" {
  name     = "config-${var.region}"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}


resource "aws_config_delivery_channel" "config" {
  name           = "config"
  s3_bucket_name = aws_s3_bucket.config.bucket
  s3_key_prefix  = var.bucket_key_prefix
  #sns_topic_arn  = "${var.sns_topic_arn}"

  snapshot_delivery_properties {
    delivery_frequency = "Three_Hours"
  }

  depends_on = [aws_config_configuration_recorder.config]
}

#Starting the Config Configuration Recorder
resource "aws_config_configuration_recorder_status" "config" {
  name       = aws_config_configuration_recorder.config.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.config]
}