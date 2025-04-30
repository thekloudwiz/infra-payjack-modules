# Retrieve ALB Service Account Credentials
data "aws_elb_service_account" "main" {}

##############################################################################

# Local Variables for Naming Conventions
locals {
  # Naming convention for resources
  name_prefix = "${var.environment}-${var.project_name}"

  # Common tags for all resources
  common_tags = {
    Environment = var.environment
    Managed_by  = var.managed_by
    Owner       = var.owner
    Project     = "${var.project_name}"
  }
}

# Local variables for resource names
locals {
  alb_logs_bucket_name = "${local.name_prefix}-alb-logs-bucket"
}

##############################################################################

# Generate a random string for ALB logs bucket name suffix
resource "random_id" "random_string" {
  byte_length = 4
}

# Create S3 bucket for ALB logs
resource "aws_s3_bucket" "alb_logs" {
  bucket        = "${local.alb_logs_bucket_name}-${random_id.random_string.hex}"
  force_destroy = true

  tags = merge(local.common_tags, {
    Name = "${local.alb_logs_bucket_name}-${random_id.random_string.hex}"
    })
}

# Block public access
resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable Access Logging on ALB logs
resource "aws_s3_bucket_logging" "alb_logs" {
  bucket        = aws_s3_bucket.alb_logs.id
  target_bucket = aws_s3_bucket.alb_logs.id
  target_prefix = "logs/"
}

# Create S3 bucket policy for ALB logs
resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_elb_service_account.main.id}:root"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/*"
      }
    ]
  })
}

# Enable versioning on ALB logs
resource "aws_s3_bucket_versioning" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable event notification on ALB logs
resource "aws_s3_bucket_notification" "alb_logs" {
  bucket      = aws_s3_bucket.alb_logs.id
  eventbridge = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# Save Logs Bucket name in SSM Parameter Store
resource "aws_ssm_parameter" "alb_logs_bucket_name" {
  name  = "/${local.name_prefix}/alb-logs-bucket-name"
  type  = "String"
  value = aws_s3_bucket.alb_logs.bucket

  depends_on = [aws_s3_bucket.alb_logs]
}