# Configure AWS Provider
provider "aws" {
  region = var.region
  # profile = "OTAssumeInfraBeginnerPermSet-509399591563"
}


# Configure AWS Provider for S3 Backend
# terraform {
#  required_providers {
#    aws = {
#      source  = "hashicorp/aws"
#    version = "~> 5.0"
#   }
#  }

#  backend "s3" {
#    bucket       = "dev-payjack-tf-state"
#   key          = "infra/terraform.tfstate"
#    region       = "eu-west-1"
#   encrypt      = true
#    use_lockfile = true
# }
# }