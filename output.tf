# ----------------------------
# General Information
# ----------------------------

# Output the AWS region in which resources are deployed
output "region" {
  description = "The AWS region where resources are deployed"
  value       = var.region
}

# Output the project name
output "project_name" {
  description = "The project name"
  value       = var.project_name
}

# ----------------------------
# Networking Outputs
# ----------------------------

# Output the VPC ID created
output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

# Output the list of public subnet IDs
output "public_subnets_ids" {
  description = "List of public subnet IDs"
  value       = module.networking.public_subnet_ids
}

# Output the CIDR blocks of public subnets
output "public_subnet_cidr" {
  description = "CIDR blocks of public subnets"
  value       = module.networking.public_subnet_cidr
}

# Output the list of App private subnet IDs
output "app_subnets_ids" {
  description = "List of private subnet IDs"
  value       = module.networking.app_subnet_ids
}

# Output the CIDR blocks of App private subnets
output "app_subnet_cidr" {
  description = "CIDR blocks of App private subnets"
  value       = module.networking.app_subnet_cidr
}

# Output the list of DB private subnet IDs
output "db_subnets_ids" {
  description = "List of private subnet IDs"
  value       = module.networking.db_subnet_ids
}

# Output the CIDR blocks of DB private subnets
output "db_subnet_cidr" {
  description = "CIDR blocks of DB private subnets"
  value       = module.networking.db_subnet_cidr
}

# Output the Elastic IP in the Networking Module
output "nat_eip" {
  description = "Elastic IP in the Networking Module"
  value       = module.networking.nat_eip
}

# Output NAT ID in the Networking Module
output "nat_id" {
  description = "NAT ID in the Networking Module"
  value       = module.networking.nat_id
}

# Output Public Route Table ID in the Networking Module
output "public_rt_id" {
  description = "Public Route Table ID in the Networking Module"
  value       = module.networking.public_rtb_id
}

# Output Private Route Table ID in the Neworking Module
output "private_rt_id" {
  description = "Private Route Table ID in the Networking Module"
  value       = module.networking.private_rtb_id
}

# ----------------------------
# Security Group Outputs
# ----------------------------

# Output the Jump Box Security Group ID
output "jump_sg_id" {
  description = "Security Group ID for Jump Box"
  value       = module.security.jump_sg_id
}

# Output the ALB Security Group ID
output "alb_sg_id" {
  description = "Security Group ID for ALB"
  value       = module.security.alb_sg_id
}


# Output the ECS Security Group ID
output "ecs_sg_id" {
  description = "Security Group ID for ECS"
  value       = module.security.ecs_sg_id
}

# Output the mssql Security Group ID
output "mysql_sg_id" {
  description = "Security Group ID for the RDS Instance"
  value       = module.security.mssql_sg_id
}

# Output the Postgres Security Group ID
output "postgress_sg_id" {
  description = "Security Group ID for the RDS Instance"
  value       = module.security.postgres_sg_id
}

# Output Redis SG ID
output "redis_sg_id" {
  value = module.security.valkey_sg_id
}

# Output Kafka SG ID
output "kafka_sg_id" {
  value = module.security.kafka_sg_id
}


# # ----------------------------
# # IAM Outputs
# # ----------------------------

# Output the IAM instance profile ARN used by EC2
output "instance_profile_arn" {
  description = "IAM instance profile attached to EC2 instances"
  value       = module.iam.ec2_instance_profile_arn
}

# Output ECS Task Execution Role ARN
output "ecs_task_execution_role_arn" {
  description = "ARN of ECS task execution role"
  value       = module.iam.ecs_task_execution_role_arn
}

# Output ECS Task Role ARN
output "ecs_task_role_arn" {
  description = "ARN of ECS task role"
  value       = module.iam.ecs_task_role_arn
}

# Output ECS Execution Role ARN
output "ecs_execution_role_arn" {
  description = "ARN of ECS execution role"
  value       = module.iam.ecs_execution_role_arn
}

# Output Native Backup IAM Role ARN
output "native_backup_iam_role_arn" {
  description = "ARN of Native Backup IAM Role"
  value       = module.iam.native_backup_iam_role_arn
}

# ----------------------------
# Load Balancer Outputs
# ----------------------------

# Output the DNS name of the ALB
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.load_balancer.alb_dns_name
}

# ----------------------------
# Compute (EC2) Outputs
# ----------------------------

# Output the Hostname of EC2 instances created
output "ec2_instance_hostname" {
  description = "List of EC2 instance IDs"
  value       = module.compute.jump_box_dns
}

# Output the private IPs of EC2 instances
output "ec2_private_ip" {
  description = "Private IP addresses of EC2 instances"
  value       = module.compute.admin_private_ip
}

# Output the ID of the EC2 Instance Created
output "ec2_instance_id" {
  description = "List of EC2 instance IDs"
  value       = module.compute.jump_box_id
}

# Output ECS Cluster ARN
output "ecs_cluster_arn" {
  description = "ARN of ECS cluster"
  value       = module.compute.ecs_cluster_arn
}

# Output ECS Cluster ID
output "ecs_cluster_id" {
  description = "ID of ECS cluster"
  value       = module.compute.ecs_cluster_id
}



# # ----------------------------
# # Database (RDS) Outputs
# # ----------------------------

# Output the endpoint of the RDS instance
output "rds_endpoint" {
  description = "RDS mssql database endpoint"
  value       = module.database.mssql_endpoint
}

# Output RDS Postgres endpoint
output "postgres_endpoint" {
  description = "RDS Postgres database endpoint"
  value       = module.database.postgres_endpoint
}

# ----------------------------
# ElastiCache (Valkey) Outputs
# ----------------------------

# Output the Valkey endpoints (primary, reader, and optionally configuration) from the services module
output "valkey_endpoints" {
  description = "Endpoints for the ElastiCache Valkey cluster (primary, reader, configuration)"
  value       = module.services.valkey_endpoints
}

# ----------------------------
# Kafka (MSK) Outputs
# ----------------------------

# Output the bootstrap broker endpoints for MSK
output "msk_bootstrap_brokers" {
  description = "Bootstrap broker string for Kafka MSK cluster"
  value       = module.services.msk_bootstrap_brokers_plaintext
}

# Output the MSK cluster bootstrap brokers for TLS connections
output "msk_bootstrap_brokers_tls" {
  value = module.services.msk_bootstrap_brokers_tls
}

# Output the MSK cluster bootstrap brokers for SASL SCRAM authentication
output "msk_bootstrap_brokers_sasl_scram" {
  value = module.services.msk_bootstrap_brokers_sasl_scram
}