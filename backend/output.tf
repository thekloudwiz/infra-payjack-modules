# Output State Bucket Name
output "state_bucket_name" {
  value = aws_s3_bucket.state_bucket.id
}