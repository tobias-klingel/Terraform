#Provider for terraform is AWS
provider "aws"{
    region = var.aws-region
    allowed_account_ids=[var.aws-account-id]
}