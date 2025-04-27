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


###############################################################################

# Local Variables for Naming Conventions
locals {
  # Naming convention for resources
  name_prefix = "${var.environment}-${var.project_name}"

  # Common tags for all resources
  common_tags = {
    Environment = var.environment
    AName       = var.region
    Managed_by  = var.managed_by
    Owner       = var.owner
    Project     = "${var.project_name}"
  }
}

# Local variables for resource names
locals {
  instance_name       = "${local.name_prefix}-app-server"
  jump_server_name    = "${local.name_prefix}-jump-box"
  asg_name            = "${local.name_prefix}-asg"
  ecr_repository_name = "${local.name_prefix}-ecr-repo"
  ecs_service_name    = "${local.name_prefix}-ecs-service"
  container_name      = "${local.name_prefix}-container"
  task_family_name    = "${local.name_prefix}-task-family"
  ecs_cluster_name    = "${local.name_prefix}-ecs-cluster"
}

###############################################################################

# Jump Box EC2 Instance
resource "aws_instance" "jump_box" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = var.ec2_instance_type
  subnet_id            = split(",", data.aws_ssm_parameter.public_subnet_ids.value)[0]
  iam_instance_profile = data.aws_iam_instance_profile.ec2_profile.name
  security_groups      = [data.aws_ssm_parameter.jump_sg_id.value]
  key_name             = var.key_name

  credit_specification {
    cpu_credits = var.cpu_credits
  }

  lifecycle {
    ignore_changes = [
      security_groups,
      user_data,
      tags
    ]
  }

  tags = merge(local.common_tags,
    {
      Name = "${local.jump_server_name}"
  })
}
# -----------------------------------------------------------------------------------------
# KMS Key for ECR
# Create KMS Key for ECR
resource "aws_kms_key" "ecr_key" {
  description             = "KMS key for ${local.ecr_repository_name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  # Key policy
  policy = templatefile("${path.root}/policies/kms-policy.json", {
    account_id = data.aws_caller_identity.current.account_id
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ecr-key"
  })

  lifecycle {
    ignore_changes = [policy, tags]
  }
}

# Create KMS Alias for ECR
resource "aws_kms_alias" "ecr_key_alias" {
  name          = "alias/${local.name_prefix}-ecr-key"
  target_key_id = aws_kms_key.ecr_key.key_id
}

# -------------------------------------------------------------------------------------------

# Create ECR Repository
resource "aws_ecr_repository" "ecr_repo" {
  name         = local.ecr_repository_name
  force_delete = true

  # Ensure image tags are immutable
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.ecr_key.arn
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.common_tags, {
    Name = local.ecr_repository_name
  })
}

# ECR lifecycle policy
resource "aws_ecr_lifecycle_policy" "repo_policy" {
  repository = aws_ecr_repository.ecr_repo.name

  policy = file("${path.root}/policies/ecr-lifecycle-policy.json")
}

# -------------------------------------------------------------------------------------------
# Add service discovery
resource "aws_service_discovery_private_dns_namespace" "ecs" {
  name        = "${local.name_prefix}.local"
  description = "Service Discovery Namespace for ECS"
  vpc         = data.aws_ssm_parameter.vpc_id.value

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}.local"
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      name,
      description,
      vpc
    ]
  }
}

# Create Service Discovery Service for ECS
resource "aws_service_discovery_service" "ecs" {
  name = local.ecs_service_name

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.ecs.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = merge(local.common_tags, {
    Name = local.ecs_service_name
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      name,
      description
    ]
  }
}
# -------------------------------------------------------------------------------------------
# ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = local.ecs_cluster_name

  #Enable container insights
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(local.common_tags, {
    Name        = local.ecs_cluster_name,
    Environment = var.environment,
    Project     = var.project_name,
    Owner       = var.owner
  })
}

# ECS Task Definition
resource "aws_ecs_task_definition" "task" {
  family                   = local.task_family_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  task_role_arn            = data.aws_ssm_parameter.ecs_task_role_arn.value
  execution_role_arn       = data.aws_ssm_parameter.ecs_execution_role_arn.value

  container_definitions = jsonencode([
    {
      name      = local.container_name
      image     = "${aws_ecr_repository.ecr_repo.repository_url}:latest"
      cpu       = var.task_cpu
      memory    = var.task_memory
      user      = var.container_user
      essential = true

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"             = "/ecs/${local.name_prefix}"
          "awslogs-region"            = var.region
          "awslogs-stream-prefix"     = "ecs"
          "awslogs-multiline-pattern" = "^\\[\\d{4}-\\d{2}-\\d{2}" # For better log parsing
        }
      }

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      healthCheck = {
        command = [
          "CMD-SHELL",
          "curl -f http://localhost:${var.container_port}/health || exit 1"
        ]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }

      # Enhanced container security settings
      readonlyRootFilesystem = true
      privileged             = false

      linuxParameters = {
        initProcessEnabled = true
        capabilities = {
          drop = ["ALL"]
        }
      }

      environment = [
        {
          name  = "NODE_ENV"
          value = var.environment
        },
        {
          name  = "APP_VERSION"
          value = var.app_version
        }
      ]

      mountPoints = []
      volumesFrom = []
    }
  ])

  lifecycle {
    ignore_changes = [
      container_definitions,
      task_role_arn,
      execution_role_arn,
    ]
  }

  tags = merge(local.common_tags, {
    Name        = local.task_family_name,
    Environment = var.environment,
    Project     = var.project_name,
    Owner       = var.owner
  })
}

# ECS Service with Auto Scaling
resource "aws_ecs_service" "ecs_service" {
  name                               = local.ecs_service_name
  cluster                            = aws_ecs_cluster.ecs_cluster.arn
  task_definition                    = aws_ecs_task_definition.task.arn
  launch_type                        = "FARGATE"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  force_new_deployment               = true

  network_configuration {
    subnets          = split(",", data.aws_ssm_parameter.app_subnet_ids.value)
    security_groups  = [data.aws_ssm_parameter.ecs_sg_id.value]
    assign_public_ip = false

  }

  load_balancer {
    target_group_arn = data.aws_ssm_parameter.alb_target_group_arn.value
    container_name   = local.container_name
    container_port   = var.container_port
  }

  deployment_controller {
    type = "ECS"
  }
  desired_count = var.availability_zones_count

  lifecycle {
    ignore_changes = [desired_count]
  }

  enable_execute_command = false

  service_registries {
    registry_arn = aws_service_discovery_service.ecs.arn
  }

  tags = merge(local.common_tags, {
    Name        = local.ecs_service_name,
    Environment = var.environment,
    Project     = var.project_name,
    Owner       = var.owner
  })
}

# Auto Scaling Configuration
resource "aws_appautoscaling_target" "ecs_scaling_target" {
  max_capacity       = var.ecs_max_capacity
  min_capacity       = var.availability_zones_count
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# CPU-based Auto Scaling
resource "aws_appautoscaling_policy" "cpu_scaling" {
  name               = "${local.name_prefix}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.cpu_target_value
    scale_in_cooldown  = 300
    scale_out_cooldown = 300

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

# Memory-based Auto Scaling
resource "aws_appautoscaling_policy" "memory_scaling" {
  name               = "${local.name_prefix}-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.memory_target_value
    scale_in_cooldown  = 300
    scale_out_cooldown = 300

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}

#-------------------------------------------------------------------------------------------
# Store Cluster ARN
resource "aws_ssm_parameter" "ecs_cluster_arn" {
  name       = "/${local.name_prefix}/ecs_cluster_arn"
  type       = "String"
  value      = aws_ecs_cluster.ecs_cluster.arn
  tags       = local.common_tags
  depends_on = [aws_ecs_cluster.ecs_cluster]

}

# Store ECS Cluster ID
resource "aws_ssm_parameter" "ecs_cluster_id" {
  name       = "/${local.name_prefix}/ecs_cluster_id"
  type       = "String"
  value      = aws_ecs_cluster.ecs_cluster.id
  tags       = local.common_tags
  depends_on = [aws_ecs_cluster.ecs_cluster]

}

# Store ECS Task Definition ARN
resource "aws_ssm_parameter" "ecs_task_definition_arn" {
  name       = "/${local.name_prefix}/ecs_task_definition_arn"
  type       = "String"
  value      = aws_ecs_task_definition.task.arn
  tags       = local.common_tags
  depends_on = [aws_ecs_task_definition.task]
}