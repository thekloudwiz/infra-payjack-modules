# Local varibales for Naming conventions

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
  waf_acl_name     = "${local.name_prefix}-waf-acl"
  waf_metric_name  = "${local.name_prefix}-waf-metric"
  jump_sg_name     = "${local.name_prefix}-jump-sg"
  ecs_sg_name      = "${local.name_prefix}-ecs-sg"
  mssql_sg_name    = "${local.name_prefix}-mssql-sg"
  postgres_sg_name = "${local.name_prefix}-postgres-sg"
  valkey_sg_name   = "${local.name_prefix}-valkey-sg"
  alb_sg_name      = "${local.name_prefix}-alb-sg"
  kafka_sg_name    = "${local.name_prefix}-kafka-sg"
}

# --------------------------------------------------------------------------

# Retrieve VPC ID from SSM
data "aws_ssm_parameter" "vpc_id" {
  name = "/${local.name_prefix}/vpc_id"
}

# --------------------------------------------------------------------------

# Create WAF for ALB Against OWASP Top 10)
resource "aws_wafv2_web_acl" "alb_waf" {
  name        = local.waf_acl_name
  scope       = "REGIONAL"
  description = "WAF for ALB protecting against OWASP Top 10"
  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = local.waf_metric_name
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "awsCommonRules"
      sampled_requests_enabled   = true
    }
  }

  tags = local.common_tags
}


# Create Security Group for Jump Box
resource "aws_security_group" "jump_sg" {
  name        = local.jump_sg_name
  description = "Security group for Jump Box"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = local.jump_sg_name
  })
}

# Create Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = local.alb_sg_name
  description = "ALB SG: Allow HTTP/HTTPS from anywhere"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = [var.public_destination_cidr]
  }

  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = [var.public_destination_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.public_destination_cidr]
  }

  tags = merge(local.common_tags, {
    Name = local.alb_sg_name
  })
}

# Create Security Group for ECS
resource "aws_security_group" "ecs_sg" {
  name        = local.ecs_sg_name
  description = "ECS SG: Allow traffic from ALB"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  ingress {
    from_port       = var.http_port
    to_port         = var.http_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port       = var.http_port
    to_port         = var.http_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.public_destination_cidr]
  }

  tags = merge(local.common_tags, {
    Name = local.ecs_sg_name
  })
}

# Create Security Group for mssql
resource "aws_security_group" "mssql_sg" {
  name        = local.mssql_sg_name
  description = "mssql SG: Allow traffic from ECS"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  ingress {
    from_port       = var.mssql_port
    to_port         = var.mssql_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.public_destination_cidr]
  }

  tags = merge(local.common_tags, {
    Name = local.mssql_sg_name
  })
}

# Create Security Group for Postgres
resource "aws_security_group" "postgres_sg" {
  name        = local.postgres_sg_name
  description = "Postgres SG: Allow traffic from ECS"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  ingress {
    from_port       = var.postgres_port
    to_port         = var.postgres_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.public_destination_cidr]
  }

  tags = merge(local.common_tags, {
    Name = local.postgres_sg_name
  })
}

# Create Security Group for Vlakey
resource "aws_security_group" "valkey_sg" {
  name        = local.valkey_sg_name
  description = "Valkey SG: Allow traffic from ECS"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  ingress {
    from_port       = var.valkey_port
    to_port         = var.valkey_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.public_destination_cidr]
  }

  tags = merge(local.common_tags, {
    Name = local.jump_sg_name
  })
}

# Create Security Group for Kafka
resource "aws_security_group" "kafka_sg" {
  name        = local.kafka_sg_name
  description = "Kafka SG: Allow traffic from ECS"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  ingress {
    from_port       = var.kafka_port
    to_port         = var.kafka_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.public_destination_cidr]
  }

  tags = merge(local.common_tags, {
    Name = local.jump_sg_name
  })
}

# -----------------------------------------------------------------

# Save Security Credentials in SSM Parameter Store

# Save WAF ACL ARN in SSM Parameter Store
resource "aws_ssm_parameter" "waf_acl_arn" {
  name  = "/${local.name_prefix}/waf_acl_arn"
  type  = "String"
  value = aws_wafv2_web_acl.alb_waf.arn

  tags = local.common_tags
}

# Save Jump Box Security Group ID in SSM Parameter Store
resource "aws_ssm_parameter" "jump_sg_id" {
  name  = "/${local.name_prefix}/jump_sg_id"
  type  = "String"
  value = aws_security_group.jump_sg.id

  tags = local.common_tags
}

# Save ALB Security Group ID in SSM Parameter Store
resource "aws_ssm_parameter" "alb_sg_id" {
  name  = "/${local.name_prefix}/alb_sg_id"
  type  = "String"
  value = aws_security_group.alb_sg.id

  tags = local.common_tags
}

# Save ECS Security Group ID in SSM Parameter Store
resource "aws_ssm_parameter" "ecs_sg_id" {
  name  = "/${local.name_prefix}/ecs_sg_id"
  type  = "String"
  value = aws_security_group.ecs_sg.id

  tags = local.common_tags
}

# Save mssql Security Group ID in SSM Parameter Store
resource "aws_ssm_parameter" "mssql_sg_id" {
  name  = "/${local.name_prefix}/mssql_sg_id"
  type  = "String"
  value = aws_security_group.mssql_sg.id

  tags = local.common_tags
}

# Save Postgres Security Group ID in SSM Parameter Store
resource "aws_ssm_parameter" "postgres_sg_id" {
  name  = "/${local.name_prefix}/postgres_sg_id"
  type  = "String"
  value = aws_security_group.postgres_sg.id

  tags = local.common_tags
}

# Save Redis Security Group ID in SSM Parameter Store
resource "aws_ssm_parameter" "valkey_sg_id" {
  name  = "/${local.name_prefix}/valkey_sg_id"
  type  = "String"
  value = aws_security_group.valkey_sg.id

  tags = local.common_tags
}

# Save Kafka Security Group ID in SSM Parameter Store
resource "aws_ssm_parameter" "kafka_sg_id" {
  name  = "/${local.name_prefix}/kafka_sg_id"
  type  = "String"
  value = aws_security_group.kafka_sg.id

  tags = local.common_tags
}