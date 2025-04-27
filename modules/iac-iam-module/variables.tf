# Region
variable "region" {
  description = "AWS region to deploy resources"
  type        = string
}

# Managed By
variable "managed_by" {
  description = "Managed by information"
  type        = string
}

# Owner
variable "owner" {
  description = "Owner information"
  type        = string
}

# Environment
variable "environment" {
  description = "Environment name"
  type        = string
}

# Project Name
variable "project_name" {
  description = "Project name"
  type        = string
}

# SSM Maintenance Window Policy ARN
variable "iam_ssm_maintenance_window_policy_arn" {
  description = "Amazon SSM Maintenance policy ARN"
  type        = string
}

# SSM Managed Instance Core Policy ARN
variable "iam_ssm_managed_instance_core_policy_arn" {
  description = "Amazon SSM Managed Instance Core policy ARN"
  type        = string
}

# EC2 SSM Policy ARN
variable "iam_ec2_ssm_policy_arn" {
  description = "Amazon EC2 Role for SSM policy ARN"
  type        = string
}

# SSM Pacth Association Role Policy for Resource Patching with SSM ARN
variable "amazon_ssm_patch_association_policy_arn" {
  description = "Role Policy for SSM Patching"
  type        = string
}