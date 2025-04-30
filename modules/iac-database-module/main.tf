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


# Local variables for mssql db
locals {
  mssql_db_name              = "${local.name_prefix}-mssql-db"
  mssql_db_instance_name     = "${local.name_prefix}-mssql-db-instance"
  mssql_db_subnet_group_name = "${local.name_prefix}-db-subnet-group"
  mssql_secret_name          = "${local.name_prefix}mssql-secret"
}

# Local variables for postgres db
locals {
  postgres_secret_name          = "${local.name_prefix}-postgres-secret"
  postgres_db_name              = "${local.name_prefix}-postgres-db"
  postgres_db_instance_name     = "${local.name_prefix}-postgres-db-instance"
  postgres_db_subnet_group_name = "${local.name_prefix}-postgres-db-subnet-group"
}

#############################################################################

# Create a mssql RDS instance in a VPC with a security group and subnet group
# Create mssql Subnet Group
resource "aws_db_subnet_group" "mssql" {
  name       = local.mssql_db_subnet_group_name
  subnet_ids = split(",", data.aws_ssm_parameter.db_private_subnet_ids.value)

  tags = merge(
    local.common_tags,
    {
      Name = "${local.mssql_db_subnet_group_name}"
  })
}

# Create Postgres Subnet Group
resource "aws_db_subnet_group" "postgres" {
  name       = local.postgres_db_subnet_group_name
  subnet_ids = split(",", data.aws_ssm_parameter.db_private_subnet_ids.value)

  tags = merge(
    local.common_tags,
    {
      Name = "${local.postgres_db_subnet_group_name}"
  })
}

# Create a random password for mssql
resource "random_password" "mssql" {
  length           = 16
  special          = true
  upper            = true
  lower            = true
  numeric          = true
  override_special = "_%#!$^&*"
}

# Create a random password for Postgres
resource "random_password" "postgres" {
  length           = 16
  special          = true
  upper            = true
  lower            = true
  numeric          = true
  override_special = "_%#!$^&*"
}

# Random String Generator for Secret Name
resource "random_id" "random_string" {
  byte_length = 4
}

# Create A Secret Manager for RDS mssql Credentials
resource "aws_secretsmanager_secret" "mssql" {
  # name        = local.mssql_secret_name
  name        = "${local.mssql_secret_name}-${random_id.random_string.hex}"
  description = "DB Credentials credentials for ${local.mssql_db_name}"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.mssql_secret_name}-${random_id.random_string.hex}"
  })
}

# Create a Secret Version for RDS mssql DB Credentials
resource "aws_secretsmanager_secret_version" "mssql" {
  secret_id = aws_secretsmanager_secret.mssql.id

  secret_string = jsonencode({
    username = var.mssql_db_username
    password = random_password.mssql.result
  })
}


# Create A Secret Manager for RDS Postgres Credentials
resource "aws_secretsmanager_secret" "postgres" {
  # name        = local.postgres_secret_name
  name        = "${local.postgres_secret_name}-${random_id.random_string.hex}"
  description = "DB Credentials credentials for ${local.postgres_db_name}"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.postgres_db_name}-secret"
  })
}

# Create a Secret Version for RDS Postgres DB Credentials
resource "aws_secretsmanager_secret_version" "postgres" {
  secret_id = aws_secretsmanager_secret.postgres.id

  secret_string = jsonencode({
    username = var.postgres_db_username
    password = random_password.postgres.result
  })
}

# Local variables for mssql DB Name
locals {
  mssql_db_option_group_name = "${local.name_prefix}-${random_id.random_string.hex}"
}

# Local variables for mssql DB Credentials
locals {
  mssql_db_creds = jsondecode(data.aws_secretsmanager_secret_version.mssql_db_creds.secret_string)

}

# Local variables for Postgres DB Credentials
locals {
  postgres_db_creds = jsondecode(data.aws_secretsmanager_secret_version.postgres_db_creds.secret_string)

}

##############################################################################

# Retrieve RDS Data from SSM Parameter Store
# Retrieve Private Subnet IDs from SSM Parameter Store
data "aws_ssm_parameter" "db_private_subnet_ids" {
  name = "/${local.name_prefix}/db_subnet_ids"
}

# Retrieve mssql DB Credentials
data "aws_secretsmanager_secret_version" "mssql_db_creds" {
  secret_id = aws_secretsmanager_secret.mssql.id

  depends_on = [aws_secretsmanager_secret_version.mssql]
}

# Retrieve Postgres DB Credentials
data "aws_secretsmanager_secret_version" "postgres_db_creds" {
  secret_id = aws_secretsmanager_secret.postgres.id

  depends_on = [aws_secretsmanager_secret_version.postgres]
}

# Retrieve RDS MSSQL Security Group ID from SSM Parameter Store
data "aws_ssm_parameter" "mssql_sg_id" {
  name = "/${local.name_prefix}/mssql_sg_id"
}

# Retrieve RDS Postgres Security Group ID from SSM Parameter Store
data "aws_ssm_parameter" "postgres_sg_id" {
  name = "/${local.name_prefix}/postgres_sg_id"
}

# Retrieve RDS Enhanced Monitoring Role ARN from SSM Parameter Store
data "aws_ssm_parameter" "rds_enhanced_monitoring_role_arn" {
  name = "/${local.name_prefix}/rds_enhanced_monitoring_role_arn"
}
# Retrieve RDS Native Backup Role ARN from SSM Parameter Store
data "aws_iam_role" "rds_nativebackup_role_arn" {
  name = "${local.name_prefix}-rds-nativebackup-role"
}

#--------------------------------------------------------------------------
# Create MSSQL and Postgres DB Instances
#--------------------------------------------------------------------------

# Create Options Group for RDS MSSQL
resource "aws_db_option_group" "mssql" {
  name                     = "${local.mssql_db_option_group_name}"
  engine_name              = var.mssql_db_engine
  major_engine_version     = "15.00"
  option_group_description = "MSSQL Option Group for ${local.name_prefix}"

  option {
    option_name = "SQLSERVER_BACKUP_RESTORE"

    option_settings {
      name  = "IAM_ROLE_ARN"
      value = data.aws_iam_role.rds_nativebackup_role_arn.arn
    }
  }
}

# Create MSSQL DB Instance
resource "aws_db_instance" "mssql" {
  identifier                   = local.mssql_db_instance_name
  allocated_storage            = var.db_storage_size
  max_allocated_storage        = var.db_max_allocated_storage
  license_model                = "license-included"
  storage_type                 = var.storage_type
  engine                       = var.mssql_db_engine
  engine_version               = "15.00.4345.5.v1"
  instance_class               = var.db_instance_class
  multi_az                     = var.multi_az
  username                     = local.mssql_db_creds.username
  password                     = local.mssql_db_creds.password
  vpc_security_group_ids       = [data.aws_ssm_parameter.mssql_sg_id.value]
  db_subnet_group_name         = aws_db_subnet_group.mssql.name
  backup_retention_period      = 3
  skip_final_snapshot          = var.skip_final_snapshot
  storage_encrypted            = var.storage_encrypted
  monitoring_interval          = 60
  monitoring_role_arn          = data.aws_ssm_parameter.rds_enhanced_monitoring_role_arn.value
  performance_insights_enabled = true
  option_group_name            = aws_db_option_group.mssql.name
  publicly_accessible          = false

  lifecycle {
    ignore_changes = [
      monitoring_interval,
      option_group_name
    ]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.mssql_db_name}"
  })
}

# Create RDS Postgres DB Instance
resource "aws_db_instance" "postgres" {
  identifier             = local.postgres_db_instance_name
  engine                 = var.postgres_db_engine
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_storage_size
  storage_encrypted = var.storage_encrypted
  storage_type = var.storage_type
  db_name                = var.postgres_db_name
  username               = var.postgres_db_username
  password               = random_password.postgres.result
  vpc_security_group_ids = [data.aws_ssm_parameter.postgres_sg_id.value]
  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  skip_final_snapshot    = var.skip_final_snapshot
  publicly_accessible    = false
  multi_az               = var.multi_az

  lifecycle {
    ignore_changes = [
      username,
      password,
      engine_version,
      allocated_storage,
      storage_type,
      iops,
      db_subnet_group_name,
      engine,
      identifier,
      instance_class,
      db_name,
      vpc_security_group_ids
    ]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.postgres_db_name}"
  })
}

# --------------------------------------------------------------------------------------
# Save DB Endpoints in SSM Parameter Store
resource "aws_ssm_parameter" "mssql_db_endpoint" {
  name  = "/${local.name_prefix}/mssql-db-endpoint"
  type  = "String"
  value = aws_db_instance.mssql.endpoint
}

resource "aws_ssm_parameter" "postgres_db_endpoint" {
  name  = "/${local.name_prefix}/postgres-db-endpoint"
  type  = "String"
  value = aws_db_instance.postgres.endpoint
}