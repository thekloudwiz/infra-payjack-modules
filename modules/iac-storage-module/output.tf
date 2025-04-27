# Output ALB Logs Bucket ID
output "alb_logs_s3_bucket_id" {
  value = aws_s3_bucket.alb_logs.id
}

# Out ALB Logs Bucket ARN
output "alb_logs_s3_bucket_arn" {
  value = aws_s3_bucket.alb_logs
}