provider "aws" {
  region = "ap-southeast-1"
}


########################################################################################
#Lambda function
###################

# Create an archive containing source
data "archive_file" "send-alerts-to-slack" {
  type        = "zip"
  source_file = "${path.module}/lambda_py_src/slack-tobi-aws-alerts-lambda.py"
  output_path = "./build/slack-tobi-aws-alerts-lambda.zip"
}


#########################################################################################
#Get the webhook from the secrets manager
###################

#Make sure you have the secret stroed as a plaintext item
#https://ap-southeast-1.console.aws.amazon.com/secretsmanager/listsecrets?region=ap-southeast-1

data "aws_secretsmanager_secret" "slack-tobi-channel-aws-alerts-webhook" {
  name = "slack-tobi-channel-aws-alerts-webhook"
}


data "aws_secretsmanager_secret_version" "slack-tobi-aws-alerts-webhook_version" {
  secret_id = data.aws_secretsmanager_secret.slack-tobi-channel-aws-alerts-webhook.id
}

#########################################################################################
#IAM for Lambda
###################

resource "aws_iam_role" "lambda-slack-tobi-aws-alerts-webhook-role" {
  name = "lambda-slack-tobi-aws-alerts-webhook"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}



#########################################################################################
#Create Lambda
###################

resource "aws_lambda_function" "slack-tobi-aws-alerts-lambda" {
  filename         = "./build/slack-tobi-aws-alerts-lambda.zip"
  function_name    = "slack-tobi-aws-alerts-lambda"
  role             = aws_iam_role.lambda-slack-tobi-aws-alerts-webhook-role.arn
  handler          = "slack-tobi-aws-alerts-lambda.lambda_handler"
  source_code_hash = data.archive_file.send-alerts-to-slack.output_base64sha256
  runtime          = "python3.9"

  environment {
    variables = {
      webhookurl           = data.aws_secretsmanager_secret_version.slack-tobi-aws-alerts-webhook_version.secret_string
      channel              = var.slack-channel-name
      username             = var.slack-user-name
    }
  }
}