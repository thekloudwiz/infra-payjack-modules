
# Create a storage bucket
module "storage" {
  source       = "./modules/iac-storage-module"
  environment  = var.environment
  project_name = var.project_name
  managed_by   = var.managed_by
  owner        = var.owner
  region       = var.region
}

# Create Networking Environment
module "networking" {
  source                   = "./modules/iac-networking-module"
  vpc_cidr                 = var.vpc_cidr
  allowed_cidr_blocks      = var.allowed_cidr_blocks
  rtb_cidr_block = var.rtb_cidr_block
  availability_zones_count = var.availability_zones_count
  environment              = var.environment
  project_name             = var.project_name
  managed_by               = var.managed_by
  owner                    = var.owner
  region                   = var.region
}

# Create Security Module
module "security" {
  source                  = "./modules/iac-security-module"
  ssh_port                = var.ssh_port
  mssql_port              = var.mssql_port
  http_port               = var.http_port
  https_port              = var.https_port
  proxy_port_start        = var.proxy_port_start
  proxy_port_end          = var.proxy_port_end
  proxy_cidr_blocks       = var.proxy_cidr_blocks
  my_ip                   = var.my_ip
  valkey_port             = var.valkey_port
  kafka_port              = var.kafka_port
  postgres_port           = var.postgres_port
  allowed_cidr_blocks = var.allowed_cidr_blocks
  environment             = var.environment
  project_name            = var.project_name
  managed_by              = var.managed_by
  owner                   = var.owner
  region                  = var.region

  depends_on = [module.networking]
}

# Create IAM Module
module "iam" {
  source                                   = "./modules/iac-iam-module"
  iam_ssm_maintenance_window_policy_arn    = var.ssm_maintenance_window_policy_arn
  iam_ssm_managed_instance_core_policy_arn = var.ssm_managed_instance_core_policy_arn
  iam_ec2_ssm_policy_arn                   = var.iam_ec2_ssm_policy_arn
  amazon_ssm_patch_association_policy_arn  = var.amazon_ssm_patch_association_policy_arn
  environment                              = var.environment
  project_name                             = var.project_name
  managed_by                               = var.managed_by
  owner                                    = var.owner
  region                                   = var.region
}

# Create Load Balancer Module
module "load_balancer" {
  source                = "./modules/iac-loadbalancer-module"
  alb_type              = var.alb_type
  target_type           = var.target_type
  health_check          = var.health_check
  health_check_port     = var.health_check_port
  health_check_protocol = var.health_check_protocol
  http_port             = var.http_port
  https_port            = var.https_port
  environment           = var.environment
  project_name          = var.project_name
  managed_by            = var.managed_by
  owner                 = var.owner
  region                = var.region

  depends_on = [module.networking, module.security, module.storage]
}

# Create Compute Module
module "compute" {
  source            = "./modules/iac-compute-module"
  region            = var.region
  key_name          = var.key_name
  ec2_instance_type = var.ec2_instance_type
  project_name      = var.project_name
  managed_by        = var.managed_by
  owner             = var.owner
  environment       = var.environment
  # container_port           = var.container_port
  # container_user           = var.container_user
  # task_cpu                 = var.task_cpu
  # task_memory              = var.task_memory
  # cpu_target_value         = var.cpu_target_value
  # memory_target_value      = var.memory_target_value
  # ecs_max_capacity         = var.ecs_max_capacity
  availability_zones_count = var.availability_zones_count

  depends_on = [module.load_balancer]
}

# Create Database Module
module "database" {
  source                          = "./modules/iac-database-module"
  rds_native_backup_role_arn      = module.iam.rds_native_backup_iam_role_arn
  db_instance_class               = var.db_instance_class
  mssql_db_engine                 = var.mssql_db_engine
  db_storage_size                 = var.db_storage_size
  mssql_db_username               = var.mssql_db_username
  mssql_db_name                   = var.mssql_db_name
  mssql_parameter_group_family    = var.mssql_parameter_group_family
  postgres_parameter_group_family = var.postgres_parameter_group_family
  max_connections                 = var.max_connections
  max_num_parallelism             = var.max_num_parallelism
  max_threshold_parallelism       = var.max_threshold_parallelism
  postgres_db_engine              = var.postgres_db_engine
  postgres_db_username            = var.postgres_db_username
  postgres_db_name                = var.postgres_db_name
  skip_final_snapshot             = var.skip_final_snapshot
  mssql_port                      = var.mssql_port
  multi_az                        = var.multi_az
  db_max_allocated_storage        = var.db_max_allocated_storage
  storage_type                    = var.storage_type
  storage_encrypted               = var.storage_encrypted
  environment                     = var.environment
  project_name                    = var.project_name
  managed_by                      = var.managed_by
  owner                           = var.owner
  region                          = var.region

  depends_on = [module.networking, module.security, module.storage, module.iam]
}

# Create Services Module
module "services" {
  source                        = "./modules/iac-services-module"
  valkey_engine                 = var.valkey_engine
  kafka_broker_nodes_count      = var.kafka_broker_nodes_count
  num_cache_clusters            = var.num_cache_clusters
  valkey_port                   = var.valkey_port
  valkey_parameter_group_family = var.valkey_parameter_group_family
  kafka_ebs_volume_size         = var.kafka_ebs_volume_size
  kafka_version                 = var.kafka_version
  kafka_instance_type           = var.kafka_instance_type
  kafka_server_properties       = var.kafka_server_properties
  availability_zones_count      = var.availability_zones_count
  elasticache_node_type         = var.elasticache_node_type
  valkey_parameter_group_name   = var.valkey_parameter_group_name
  environment                   = var.environment
  project_name                  = var.project_name
  managed_by                    = var.managed_by
  owner                         = var.owner
  region                        = var.region

  depends_on = [module.networking, module.security, module.iam]
}