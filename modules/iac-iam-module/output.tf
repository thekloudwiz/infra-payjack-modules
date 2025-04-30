# Output EC2 Instance Profile ARN
output "ec2_instance_profile_arn" {
  value = aws_iam_instance_profile.ec2_profile.arn
}

# Output ECS Task Execution Role ARN
output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

# Output ECS Task Role ARN
output "ecs_task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}

# Output ECS Execution Role ARN
output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
}

# Output Native Backup IAM Role ARN
output "rds_native_backup_iam_role_arn" {
  value = aws_iam_role.rds_nativebackup_role.arn
}
