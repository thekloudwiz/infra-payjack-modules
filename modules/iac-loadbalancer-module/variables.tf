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

# Health Check Port
variable "health_check_port" {
  description = "Port for health check"
  type        = number
}

# Health Check Protocol
variable "health_check_protocol" {
  description = "Protocol for health check"
  type        = string
}

# HTTP Port
variable "http_port" {
  description = "HTTP port"
  type        = number
}

# ALB HTTPS Port
variable "https_port" {
  description = "HTTPS port for ALB"
  type        = number
}

# ALB Type
variable "alb_type" {
  description = "Type of the ALB"
  type        = string
}

# Target Type
variable "target_type" {
  description = "Target type for the ALB"
  type        = string
}

# Health Check Variables
variable "health_check" {
  type = object({
    path                = string
    interval            = number
    timeout             = number
    healthy_threshold   = number
    unhealthy_threshold = number
  })
}