# Select latest available version of Ubuntu OS for use as a base image
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Retrieve Admin SG ID from SSM Parameter Store
data "aws_ssm_parameter" "jump_sg_id" {
  name = "/${local.name_prefix}/jump_sg_id"
}

# Retrieve VPC ID from SSM Parameter Store
data "aws_ssm_parameter" "vpc_id" {
  name = "/${local.name_prefix}/vpc_id"
}

# Retrieve Subnet IDS from SSM Parameter Store
data "aws_ssm_parameter" "public_subnet_ids" {
  name = "/${local.name_prefix}/public_subnet_ids"
}

# Retrieve Private Subnet IDs from SSM Parameter Store
data "aws_ssm_parameter" "app_private_subnet_ids" {
  name = "/${local.name_prefix}/app_subnet_ids"
}

data "aws_iam_instance_profile" "ec2_profile" {
  name = "${local.name_prefix}-ec2-profile"
}

# Retrieve current caller identity
data "aws_caller_identity" "current" {}

# Retrieve ECS Task Role ARN From SSM Parameter Store
data "aws_ssm_parameter" "ecs_task_role_arn" {
  name = "/${local.name_prefix}/ecs_task_role_arn"
}

# Retrieve ECS Execution Role ARN From SSM Parameter Store
data "aws_ssm_parameter" "ecs_execution_role_arn" {
  name = "/${local.name_prefix}/ecs_execution_role_arn"
}

# Retrieve App Subnet IDS from SSM Parameter Store
data "aws_ssm_parameter" "app_subnet_ids" {
  name = "/${local.name_prefix}/app_subnet_ids"
}

# Retrieve ECS SG ID from SSM Parameter Store
data "aws_ssm_parameter" "ecs_sg_id" {
  name = "/${local.name_prefix}/ecs_sg_id"
}

# Retrieve ALB Target Group ARN from SSM Parameter Store
data "aws_ssm_parameter" "alb_target_group_arn" {
  name = "/${local.name_prefix}/alb_target_group_arn"
}
