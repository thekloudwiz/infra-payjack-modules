# ----------------------------------------------------------
# Variable Definitions for Complete Infrastructure
# ----------------------------------------------------------

#  ---------- Common Tags  ----------------
# AWS Region
region = "eu-west-1"

# Project Name
project_name = "geekywiz"

# Owner of the resources
owner = "thekloudwiz"

# Environment name
environment = "dev"

# Managed by information
managed_by = "terraform"

#  ---------- Network, Security & Ports ----------------

# Availability Zones Count
availability_zones_count = 3

# VPC CIDR Block
vpc_cidr = "10.0.0.0/16"

# Allowed CIDR Blocks
allowed_cidr_blocks = ["0.0.0.0/0"]

# SSH Port
ssh_port = 22

# My IP
my_ip = "196.61.39.6/32"

# HTTP Port
http_port = 80

# HTTPS Port
https_port = 443

# My SQL Port
mssql_port = 1433

# Postgres Port
postgres_port = 5432

# Proxy Port Start
proxy_port_start = 80

# Proxy Port End
proxy_port_end = 20000

# Proxy CIDR Blocks
proxy_cidr_blocks = [
  "172.31.7.20/32",
  "172.31.32.21/32"
]

# #  ---------- IAM Policy ARNs ----------------

# SSM Maintenance Window Policy ARN
ssm_maintenance_window_policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMMaintenanceWindowRole"

# SSM Managed Instance Core Policy ARN
ssm_managed_instance_core_policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

# IAM EC2 SSM Policy ARN
iam_ec2_ssm_policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"

# SSM Patch Association Role Policy for Resource Patching with SSM ARN
amazon_ssm_patch_association_policy_arn = "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation"

# EC2 Full Access Policy ARN
ec2_full_access_policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"

# RDS Full Access Policy ARN
rds_full_access_policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"

# ------------ ALB Variable Definitions ------------------

# ALB Type
alb_type = "application"

# ALB Target Type
target_type = "ip"

# Health Check Variables
health_check = {
  path                = "/"
  interval            = 30
  timeout             = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
}

# Health Check Port
health_check_port = 80

# Health Check Protocol
health_check_protocol = "HTTP"

# ------------- Compute Module Variable Definitions -------------------

# Instance Type
ec2_instance_type = "t3.micro"

cpu_credits = "standard"

key_name = ""

# # Container Port
# container_port = 3000

# # Task CPU
# task_cpu = 256

# # Memory CPU
# task_memory = 512

# # Container User
# container_user = "1000:1000"

# # ECS Minimum Capacity
# ecs_max_capacity = 6

# # CPU Target value
# cpu_target_value = 70

# # Memory Target Value
# memory_target_value = 70

# ------------------ RDS Variable Definitions ------------------

# DB Instance Class
db_instance_class = "db.t3.micro"

# DB Storage Size
db_storage_size = 20

# mssql DB Engine
mssql_db_engine = "sqlserver-ex"

# mssql DB Username
mssql_db_username = "thekloudwiz"

# mssql DB Username
mssql_db_name = "geekywizmssqldb"

# DB Max Allocated Storage
db_max_allocated_storage = 100

# Storage Type
storage_type = "gp3"

# Skip Final Snapshot
skip_final_snapshot = true

# Storage Encrypted
storage_encrypted = true

# Multi-AZ Support
multi_az = false

# MSSQL Parameter Group Family
mssql_parameter_group_family = "sqlserver-ex-15.0"

# Postgres Parameter Group Family
postgres_parameter_group_family = "postgres17"

# Max Connections
max_connections = 100

# Max Degree of Parallelism
max_num_parallelism = 8

# Max Threshold of Parallelism
max_threshold_parallelism = 16

# Postgres DB Engine
postgres_db_engine = "postgres"

# Postgres DB Name
postgres_db_name = "geekywizpostgresdb"

# Postgres DB Username
postgres_db_username = "thekloudwiz"

# ------------ MSK & Elasticache Variable Definitions ------------------

# Parameter Group Name
valkey_parameter_group_name = "default.valkey8"

# Valkey Parameter Group Family
valkey_parameter_group_family = "valkey8"

# Kafka Version
kafka_version = "2.8.1"

# Valkey Engine
valkey_engine = "valkey"

# Valkey Cache Cluster Number
num_cache_clusters = 2

# Elasticache Valkey Port
valkey_port = 6379

# Elasticache Node Type
elasticache_node_type = "cache.t3.micro"

# Kafka Broker Node Count
kafka_broker_nodes_count = 2

# Kafka EBS Storage
kafka_ebs_volume_size = 30

# Kafka Port
kafka_port = 9092

# Kafka Instance Type
kafka_instance_type = "kafka.t3.small"

# MSK Server Properties
kafka_server_properties = <<EOT
auto.create.topics.enable = true
delete.topic.enable = true
log.retention.hours = 168
num.partitions = 2
EOT



# ----------------------------------------------------- Configured by @thekloudwiz ----------------------------------------------------- #