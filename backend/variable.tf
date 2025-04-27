# Variables for Backend Configuration

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

# Project Name
variable "project_name" {
  description = "Project name"
  type        = string
}

# Environment
variable "environment" {
  description = "Environment name"
  type        = string
}