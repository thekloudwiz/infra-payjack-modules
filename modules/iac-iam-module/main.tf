# Local Variables for Naming Conventions
locals {
  # Naming convention for resources
  name_prefix = "${var.environment}-${var.project_name}"

  # Common tags for all resources
  common_tags = {
    Environment = var.environment
    Managed_by  = var.managed_by
    Owner       = var.owner
    Project     = "${var.project_name}"
  }
}

# Local variables for resource names
locals {
  ec2_profile_name                  = "${local.name_prefix}-ec2-profile"
  ec2_role_name                     = "${local.name_prefix}-ec2-role"
  app_role_name                     = "${local.name_prefix}-app-role"
  app_s3_policy_name                = "${local.name_prefix}-app-s3-policy"
  ec2_assume_role_policy_name       = "${local.name_prefix}-ec2-assume-role-policy"
  ecs_task_assume_role_name         = "${local.name_prefix}-ecs-task-execution-role"
  ecs_task_execution_policy_name    = "${local.name_prefix}-ecs-task-execution-role-policy"
  ecr_pull_policy_name              = "${local.name_prefix}-ecr-pull-policy"
  task_role_name                    = "${local.name_prefix}-task-role"
  ecs_execution_role_name           = "${local.name_prefix}-ecs-execution-role"
  ecs_task_execution_role_name      = "${local.name_prefix}-ecs-task-execution-role"
  rds_native_backup_role_name       = "${local.name_prefix}-rds-nativebackup-role"
  rds_enhanced_monitoring_role_name = "${local.name_prefix}-rds-enhanced-monitoring-role"
}

###############################################################################

# Create a Data Source for EC2 Trust Policy
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Retrieve Amazon ECS Task Execution Role Policy
data "aws_iam_policy" "ecs_task_execution_policy" {
  name = "AmazonECSTaskExecutionRolePolicy"
}

# Retrieve Amazon SSM ReadOnlyAccess Policy
data "aws_iam_policy" "ssm_read_only" {
  name = "AmazonSSMReadOnlyAccess"
}

# --------------------------------------------------------------------------
# Create IAM roles and policies for EC2 instances
# ---------------------------------------------------------------------------

# Create Admin Role
resource "aws_iam_role" "ec2_role" {
  name               = local.ec2_role_name
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# Attach AWS-managed policies
resource "aws_iam_role_policy_attachment" "ec2_managed_ssm" {
  for_each = toset([
    var.iam_ssm_maintenance_window_policy_arn,
    var.iam_ssm_managed_instance_core_policy_arn,
    var.iam_ec2_ssm_policy_arn,
    var.amazon_ssm_patch_association_policy_arn,
  ])

  role       = aws_iam_role.ec2_role.name
  policy_arn = each.value
}

# Create instance profile for the admin role
resource "aws_iam_instance_profile" "ec2_profile" {
  name = local.ec2_profile_name
  role = aws_iam_role.ec2_role.name
}

# Create Roles For ECS
# Create ECS Task Execution Role and Attach Assume Role Policy
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = local.ecs_task_execution_role_name
  assume_role_policy = file("${path.root}/policies/ecs-task-assume-role-policy.json")

  tags = local.common_tags
}

# Create ECS Task Execution Role Policy and Attach to ECS Task Execution Role
resource "aws_iam_role_policy" "ecs_task_execution_role_policy" {
  name   = local.ecs_task_execution_policy_name
  role   = aws_iam_role.ecs_task_execution_role.id
  policy = file("${path.root}/policies/ecs-task-execution-role-policy.json")
}

# Create ECR Pull Policy and Attach to AWS ECS Execution Role
resource "aws_iam_role_policy" "ecr_pull_policy" {
  name   = local.ecr_pull_policy_name
  role   = aws_iam_role.ecs_execution_role.id
  policy = file("${path.root}/policies/ecr-pull-policy.json")
}

# Create ECS Task Role and Attach Assume Role Policy
resource "aws_iam_role" "ecs_task_role" {
  name = local.task_role_name

  assume_role_policy = file("${path.root}/policies/ecs-assume-role-policy.json")
}

# Create ECS Execution Role and Attach Assume Role Policy
resource "aws_iam_role" "ecs_execution_role" {
  name = local.ecs_execution_role_name

  assume_role_policy = file("${path.root}/policies/ecs-assume-role-policy.json")
}

# Attach ECS Task Execution Role policy to Execution Role
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role = aws_iam_role.ecs_execution_role.name

  policy_arn = data.aws_iam_policy.ecs_task_execution_policy.arn
}

# Add SSM access for secrets if needed
resource "aws_iam_role_policy_attachment" "ecs_task_ssm" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = data.aws_iam_policy.ssm_read_only.arn
}

#--------------------------------------------------------------------------------------------------------------------
# Create IAM roles and policies for RDS instances
# -------------------------------------------------------------------------------------------------------------------

# Create IAM Role for RDS Enhanced Monitoring
resource "aws_iam_role" "rds_enhanced_monitoring_role" {
  name = local.rds_enhanced_monitoring_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "monitoring.rds.amazonaws.com",
      },
      Effect = "Allow",
      Sid    = "",
    }],
  })
}

# Create IAM Policy for RDS Enhanced Monitoring
resource "aws_iam_policy" "rds_enhanced_monitoring_policy" {
  name        = "rds-enhanced-monitoring-policy"
  description = "Policy for RDS Enhanced Monitoring"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:CreateLogGroup",
        "s3:*"
      ],
      Effect   = "Allow",
      Resource = "*",
    }],
  })
}

# Attach IAM Policy to RDS Enhanced Monitoring Role
resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring_role.name
  policy_arn = aws_iam_policy.rds_enhanced_monitoring_policy.arn
}

# Create IAM Role for RDS Native Backup
resource "aws_iam_role" "rds_nativebackup_role" {
  name = local.rds_native_backup_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "rds.amazonaws.com",
      },
      Action = "sts:AssumeRole",
    }],
  })
}

# Create IAM Policy for RDS Native Backup
resource "aws_iam_policy" "rds_nativebackup_policy" {
  name        = "rds-nativebackup-policy"
  description = "Policy for RDS Native Backup"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "s3:*"
      ],
      Effect   = "Allow",
      Resource = "*",
    }],
  })
}

# Attach IAM Policy to RDS Native Backup Role
resource "aws_iam_role_policy_attachment" "rds_nativebackup" {
  role       = aws_iam_role.rds_nativebackup_role.name
  policy_arn = aws_iam_policy.rds_nativebackup_policy.arn
}

# --------------------------------------------------------------------------------------------------------------------
# Create SSM Parameter Store for IAM Role ARNs
# --------------------------------------------------------------------------------------------------------------------

# Store ECS Execution Role ARN in SSM Parameter Store
resource "aws_ssm_parameter" "ecs_execution_role_arn" {
  name  = "/${local.name_prefix}/ecs_execution_role_arn"
  type  = "String"
  value = aws_iam_role.ecs_execution_role.arn

  tags = local.common_tags
}

# Store ECS Task Role ARN in SSM Parameter Store
resource "aws_ssm_parameter" "ecs_task_role_arn" {
  name  = "/${local.name_prefix}/ecs_task_role_arn"
  type  = "String"
  value = aws_iam_role.ecs_task_role.arn

  tags = local.common_tags
}

# Store RDS Enhanced Monitoring Role ARN in SSM Parameter Store
resource "aws_ssm_parameter" "rds_enhanced_monitoring_role_arn" {
  name  = "/${local.name_prefix}/rds_enhanced_monitoring_role_arn"
  type  = "String"
  value = aws_iam_role.rds_enhanced_monitoring_role.arn

  tags = local.common_tags
}

# Store RDS Native Backup Role ARN in SSM Parameter Store
resource "aws_ssm_parameter" "rds_nativebackup_role_arn" {
  name  = "/${local.name_prefix}/rds_nativebackup_role_arn"
  type  = "String"
  value = aws_iam_role.rds_nativebackup_role.arn

  tags = local.common_tags

  depends_on = [aws_iam_role.rds_nativebackup_role]
}