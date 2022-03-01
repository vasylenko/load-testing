terraform {
  required_version = "1.1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.2.0"
    }
  }
}

provider "aws" {
  region = var.region

  allowed_account_ids = [var.aws_account_id]
  profile             = var.aws_profile_name
}

module "this" {
  source = "./module"

  for_each = var.list

  website       = each.value
  connections   = var.connections
  timeout       = var.timeout
  method        = var.method
  duration      = var.duration
  in_count      = var.in_count
  instance_type = var.instance_type
}
