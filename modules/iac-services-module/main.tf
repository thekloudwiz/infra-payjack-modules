# Local Variables for Naming Convention
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
  cluster_name      = "${local.name_prefix}-kafka-cluster"
  valkey_cluster_id = "${local.name_prefix}-valkey-cluster"
  subnet_group_name = "${local.name_prefix}-subnet-group"
  parameter_group_name = "${local.name_prefix}-parameter-group"
}

# Local variable to enable or disable cluster mode based on environment
locals {
  cluster_mode_enabled = var.environment == "prod" ? true : false
  db_private_subnet_ids = split(",", data.aws_ssm_parameter.db_private_subnet_ids.value)
  broker_nodes_subnets = slice(local.db_private_subnet_ids, 0, 2)
}

#############################################################################

# Retrieve Data for Services Module
# Retrieve Private Subnet IDs from SSM Parameter Store
data "aws_ssm_parameter" "db_private_subnet_ids" {
  name = "/${local.name_prefix}/db_subnet_ids"
}

data "aws_ssm_parameter" "kafa_sg_id" {
  name = "/${local.name_prefix}/kafka_sg_id"
}

# Retrieve Elasticache SG Group IDs from SSM Parameter Store
data "aws_ssm_parameter" "valkey_sg_id" {
  name = "/${local.name_prefix}/valkey_sg_id"
}

# Retrieve Kafka SG Group IDs from SSM Parameter Store
data "aws_ssm_parameter" "kafka_sg_id" {
  name = "/${local.name_prefix}/kafka_sg_id"
}

###############################################################################

# Create MSK Kafka Configuration
resource "aws_msk_configuration" "kafka" {
  name          = local.parameter_group_name
  server_properties = var.kafka_server_properties
}

# Create MSK Kafka Cluster
resource "aws_msk_cluster" "kafka" {
  cluster_name           = local.cluster_name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.kafka_broker_nodes_count

  broker_node_group_info {
    instance_type   = var.kafka_instance_type
    client_subnets  = local.broker_nodes_subnets
    security_groups = [data.aws_ssm_parameter.kafka_sg_id.value]

    storage_info {
      ebs_storage_info {
        volume_size = 30
      }
    }
  }

  encryption_info {
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  configuration_info {
    arn      = aws_msk_configuration.kafka.arn
    revision = 1
  }

  tags = merge(local.common_tags,
    {
      Name = "${local.cluster_name}"
  })

  lifecycle {
    ignore_changes = [
      broker_node_group_info[0].security_groups
    ]
  }
}

# Create Elasticache Valkey Subnet Group
resource "aws_elasticache_subnet_group" "valkey" {
  name       = local.subnet_group_name
  subnet_ids = split(",", data.aws_ssm_parameter.db_private_subnet_ids.value)
  
  tags = merge(local.common_tags,
    {
      Name = "${local.subnet_group_name}"
  })
  depends_on = [data.aws_ssm_parameter.db_private_subnet_ids]

  lifecycle {
    create_before_destroy = true
  }
}

# Create Elasticache Valkey Parameter Group
resource "aws_elasticache_parameter_group" "valkey" {
  name   = local.valkey_cluster_id
  family =  var.valkey_parameter_group_family
}

# Create Elasticache Valkey Cluster
resource "aws_elasticache_replication_group" "valkey" {
  replication_group_id       = local.valkey_cluster_id
  description                = "Elasticache Valkey Cluster"
  node_type                  = var.elasticache_node_type
  automatic_failover_enabled = var.environment == "prod" ? true : false
  multi_az_enabled           = var.environment == "prod" ? true : false
  engine                     = var.valkey_engine
  num_cache_clusters         = local.cluster_mode_enabled ? null : 1
  num_node_groups            = local.cluster_mode_enabled ? 1 : null
  replicas_per_node_group    = local.cluster_mode_enabled ? var.availability_zones_count : null
  parameter_group_name       = aws_elasticache_parameter_group.valkey.name
  port                       = var.valkey_port
  subnet_group_name          = aws_elasticache_subnet_group.valkey.name
  security_group_ids         = [data.aws_ssm_parameter.valkey_sg_id.value]
  depends_on                 = [aws_elasticache_parameter_group.valkey]

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      num_cache_clusters,
      node_type,
    ]
  }

  tags = merge(local.common_tags,
    {
      Name = "${local.valkey_cluster_id}"
  })
}