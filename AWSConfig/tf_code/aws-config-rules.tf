######################################################################################################
#General
##############################

#https://docs.aws.amazon.com/config/latest/developerguide/iam-user-mfa-enabled.html
resource "aws_config_config_rule" "IAM_USER_MFA_ENABLED" {
  name = "IAM_USER_MFA_ENABLED"

  source {
    owner             = "AWS"
    source_identifier = "IAM_USER_MFA_ENABLED"
  }
  maximum_execution_frequency = var.high_frequency_awsconfig_rules

 depends_on = [aws_config_configuration_recorder.config]
}

#https://docs.aws.amazon.com/config/latest/developerguide/access-keys-rotated.html
resource "aws_config_config_rule" "ACCESS_KEYS_ROTATED" {
  name = "ACCESS_KEYS_ROTATED"

  source {
    owner             = "AWS"
    source_identifier = "ACCESS_KEYS_ROTATED"
  }
  input_parameters = "{\"maxAccessKeyAge\":\"90\"}"

  maximum_execution_frequency = var.low_frequency_awsconfig_rules

  depends_on = [aws_config_configuration_recorder.config]
}



######################################################################################################
#Cloudtrail
##############################

#https://docs.aws.amazon.com/config/latest/developerguide/cloudtrail-enabled.html
resource "aws_config_config_rule" "CLOUD_TRAIL_ENABLED" {
  name = "CLOUD_TRAIL_ENABLED"

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_ENABLED"
  }
  maximum_execution_frequency = var.low_frequency_awsconfig_rules

  depends_on = [aws_config_configuration_recorder.config]
}


######################################################################################################
#S3 buckets
##############################

#https://docs.aws.amazon.com/config/latest/developerguide/s3-account-level-public-access-blocks.html
resource "aws_config_config_rule" "S3_ACCOUNT_LEVEL_PUBLIC_ACCESS_BLOCKS" {
  name = "S3_ACCOUNT_LEVEL_PUBLIC_ACCESS_BLOCKS"

  source {
    owner             = "AWS"
    source_identifier = "S3_ACCOUNT_LEVEL_PUBLIC_ACCESS_BLOCKS"
  }
  
  depends_on = [aws_config_configuration_recorder.config]
}

#https://docs.aws.amazon.com/config/latest/developerguide/s3-bucket-level-public-access-prohibited.html
resource "aws_config_config_rule" "S3_BUCKET_LEVEL_PUBLIC_ACCESS_PROHIBITED" {
  name = "S3_BUCKET_LEVEL_PUBLIC_ACCESS_PROHIBITED"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_LEVEL_PUBLIC_ACCESS_PROHIBITED"
  }
  
  depends_on = [aws_config_configuration_recorder.config]
}

######################################################################################################
#GuardDuty
##############################

#https://docs.aws.amazon.com/config/latest/developerguide/guardduty-enabled-centralized.html
resource "aws_config_config_rule" "GUARDDUTY_ENABLED_CENTRALIZED" {
  name             = "GUARDDUTY_ENABLED_CENTRALIZED"

  source {
    owner             = "AWS"
    source_identifier = "GUARDDUTY_ENABLED_CENTRALIZED"
  }
  maximum_execution_frequency = var.low_frequency_awsconfig_rules

  depends_on = [aws_config_configuration_recorder.config]
}


######################################################################################################
#Security groups
##############################

#https://docs.aws.amazon.com/config/latest/developerguide/vpc-sg-open-only-to-authorized-ports.html
resource "aws_config_config_rule" "VPC_SG_OPEN_ONLY_TO_AUTHORIZED_PORTS" {
  name             = "VPC_SG_OPEN_ONLY_TO_AUTHORIZED_PORTS"

  source {
    owner             = "AWS"
    source_identifier = "VPC_SG_OPEN_ONLY_TO_AUTHORIZED_PORTS"
  }
  
  /*
  input_parameters = <<POLICY
{
  "authorizedTcpPorts": "80,443"
}
POLICY
*/

  depends_on = [aws_config_configuration_recorder.config]
}