# Variables for Security Module

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

# DB Instance Class
variable "db_instance_class" {
  description = "DB instance class"
  type        = string
}

# DB Storage Size
variable "db_storage_size" {
  description = "DB storage size in GB"
  type        = number
}

# Storage Type
variable "storage_type" {
  description = "Storage type for the DB instance"
  type        = string
}

# DB Max Allocated Storage
variable "db_max_allocated_storage" {
  description = "DB max allocated storage in GB"
  type        = number
}

# DB Engine
variable "mssql_db_engine" {
  description = "mssql DB engine"
  type        = string
}

# mssql Port
variable "mssql_port" {
  description = "value of mssql port"
  type        = number
}

# MSSQL DB Username
variable "mssql_db_username" {
  description = "Username for the database"
  type        = string
}

# mssql DB Name
variable "mssql_db_name" {
  description = "Name of the database"
  type        = string
}

# MSSQL Native Backup Role ARN
variable "mssql_native_backup_role_arn" {
  description = "ARN of the MSSQL native backup role"
  type        = string
}

# Enable or Disable Multi-AZ Support for RDS MSSQL Instance
variable "multi_az" {
  description = "Enable or disable Multi-AZ support for RDS MSSQL instance"
  type        = bool
}

# Enable or Disable skip final snapshot
variable "skip_final_snapshot" {
  description = "Enable or disable skip final snapshot"
  type        = bool
}

# Enable or Disable Storage Encryption
variable "storage_encrypted" {
  description = "Enable or disable storage encryption"
  type        = bool
}

# Postgres DB Username
variable "postgres_db_username" {
  description = "Username for the database"
  type        = string
}

# Postgres DB Engine
variable "postgres_db_engine" {
  description = "Postgres DB engine"
  type        = string
}


# Postgres DB Name
variable "postgres_db_name" {
  description = "Name of the database"
  type        = string
}

