# Putput WAF ARN
output "waf_arn" {
  value = aws_wafv2_web_acl.alb_waf.arn
}

# Output SG IDS

# Output Jump SG ID
output "jump_sg_id" {
  value = aws_security_group.jump_sg.id
}


# Output ALB SG ID
output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

# Output ECS SG ID
output "ecs_sg_id" {
  value = aws_security_group.ecs_sg.id
}

# Output mssql SG ID
output "mssql_sg_id" {
  value = aws_security_group.mssql_sg.id
}


# Output Postgres SG ID
output "postgres_sg_id" {
  value = aws_security_group.postgres_sg.id
}

# Output Redis SG ID
output "valkey_sg_id" {
  value = aws_security_group.valkey_sg.id
}

# Output Kafka SG ID
output "kafka_sg_id" {
  value = aws_security_group.kafka_sg.id
}

