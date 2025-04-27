# Output RDS mssql endpoint
output "mssql_endpoint" {
  value = aws_db_instance.mssql.endpoint
}

# Output RDS Postgres endpoint
output "postgres_endpoint" {
  value = aws_db_instance.postgres.endpoint
}