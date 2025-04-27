# Output the MSK cluster bootstrap brokers for plaintext connections
output "msk_bootstrap_brokers_plaintext" {
  value       = aws_msk_cluster.kafka.bootstrap_brokers
  description = "MSK cluster bootstrap brokers for plaintext connection"
}

# Output the MSK cluster bootstrap brokers for TLS connections
output "msk_bootstrap_brokers_tls" {
  value       = aws_msk_cluster.kafka.bootstrap_brokers_tls
  description = "MSK cluster bootstrap brokers for TLS connection"
}

# Output the MSK cluster bootstrap brokers for SASL SCRAM authentication
output "msk_bootstrap_brokers_sasl_scram" {
  value       = aws_msk_cluster.kafka.bootstrap_brokers_sasl_scram
  description = "MSK cluster bootstrap brokers for SASL SCRAM authentication"
}

# Output Elasticache Cluster Endpoint
output "valkey_primary_endpoints" {
  value       = aws_elasticache_replication_group.valkey.primary_endpoint_address
  description = "List of Vlakey node endpoints and their ports"
}

# Local variable grouping all Valkey endpoints together
locals {
  valkey_endpoints = {
    primary       = aws_elasticache_replication_group.valkey.primary_endpoint_address
    reader        = aws_elasticache_replication_group.valkey.reader_endpoint_address
    configuration = local.cluster_mode_enabled ? aws_elasticache_replication_group.valkey.configuration_endpoint_address : null
  }
}

# Output all relevant Valkey endpoints in a single output for easy consumption
output "valkey_endpoints" {
  description = "All relevant Valkey endpoints (primary, reader, and optionally configuration endpoint)"
  value       = local.valkey_endpoints
}