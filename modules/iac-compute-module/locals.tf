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