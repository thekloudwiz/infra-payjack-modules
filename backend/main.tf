# Provider for AWS
provider "aws" {
  region  = var.region
  profile = "OTAssumeInfraBeginnerPermSet-509399591563"
}

# Local variables for resource names
# Naming convention for resources
locals {
  # Naming convention for resources
  name_prefix = "${var.environment}-${var.project_name}"

  # Common tags for all resources
  common_tags = {
    Environment = terraform.workspace
    Managed_by  = var.managed_by
    Owner       = var.owner
    Project     = "${var.project_name}"
  }
}

locals {
  state_bucket_name = "${local.name_prefix}-tf-state"
}

# -----------------------------------------------------------------------------------------
# Create S3 bucket for Remote State
resource "aws_s3_bucket" "state_bucket" {
  bucket = local.state_bucket_name

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(local.common_tags, {
    Name = local.state_bucket_name
  })
}

# Block public access to S3 bucket
resource "aws_s3_bucket_public_access_block" "state_bucket" {
  bucket = aws_s3_bucket.state_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning on S3 bucket
resource "aws_s3_bucket_versioning" "state_bucket" {
  bucket = aws_s3_bucket.state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}