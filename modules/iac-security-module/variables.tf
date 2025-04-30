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

# SSH Port
variable "ssh_port" {
  description = "value of ssh port"
  type        = number
}

# My IP
variable "my_ip" {
  description = "value of my ip"
  type        = string
}

# HTTP Port
variable "http_port" {
  description = "value of http port"
  type        = number
}

# HTTPS Port
variable "https_port" {
  description = "value of https port"
  type        = number
}

# Public Destination CIDR
variable "public_destination_cidr" {
  description = "value of public destination cidr"
  type        = string
}

# mssql Port
variable "mssql_port" {
  description = "value of mssql port"
  type        = number
}

# Postgres Port
variable "postgres_port" {
  description = "value of postgres port"
  type        = number
}

# Redis Port
variable "valkey_port" {
  description = "value of redis port"
  type        = number
}

# Kafka Port
variable "kafka_port" {
  description = "value of kafka port"
  type        = number
}

# Proxy Port Start
variable "proxy_port_start" {
  description = "value of proxy port start"
  type        = number
}

# Proxy Port End
variable "proxy_port_end" {
  description = "value of proxy port end"
  type        = number
}

# Proxy CIDR Blocks
variable "proxy_cidr_blocks" {
  description = "value of proxy destination cidr"
  type        = list(string)
}