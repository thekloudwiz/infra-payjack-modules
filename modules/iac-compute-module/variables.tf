# Variables for Security Module

# Availability Zones Count
variable "availability_zones_count" {
  description = "Number of AZs to use"
  type        = number
}

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

# Instance Type
variable "ec2_instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
}

# CPU Credits
variable "cpu_credits" {
  description = "Credit specification for CPU usage (standard or unlimited)"
  type        = string
  default     = "standard"
}

# KeyPair Name
variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
}

# # Container Port
# variable "container_port" {
#   description = "Port for the container"
#   type        = number
# }

# # App Version
# variable "app_version" {
#   description = "The version of the application"
#   type        = string
#   default     = "1.0.0"
# }

# # Task Definition CPU
# variable "task_cpu" {
#   description = "CPu allocation for Task Definition"
#   type        = number
# }

# # Memory Allocation for Task Definition
# variable "task_memory" {
#   description = "Memory allocation for Task Definition"
#   type        = number
# }

# # Container User
# variable "container_user" {
#   description = "User for the container"
#   type        = string
# }

# # ECS Maximum Capacity
# variable "ecs_max_capacity" {
#   description = "Maximum capacity for the ECS cluster"
#   type        = number
# }

# # CPU Target Value
# variable "cpu_target_value" {
#   description = "Target value for CPU utilization"
#   type        = number
# }

# # Memory Target Value
# variable "memory_target_value" {
#   description = "Target value for memory utilization"
#   type        = number
# }