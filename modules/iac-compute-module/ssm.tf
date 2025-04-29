# Store Cluster ARN In SSM Parameter Store
resource "aws_ssm_parameter" "ecs_cluster_arn" {
  name       = "/${local.name_prefix}/ecs_cluster_arn"
  type       = "String"
  value      = aws_ecs_cluster.ecs_cluster.arn
  tags       = local.common_tags
  depends_on = [aws_ecs_cluster.ecs_cluster]

}

# Store ECS Cluster ID In SSM Parameter Store
resource "aws_ssm_parameter" "ecs_cluster_id" {
  name       = "/${local.name_prefix}/ecs_cluster_id"
  type       = "String"
  value      = aws_ecs_cluster.ecs_cluster.id
  tags       = local.common_tags
  depends_on = [aws_ecs_cluster.ecs_cluster]

}

# Store ECS Task Definition ARN In SSM Parameter Store
resource "aws_ssm_parameter" "ecs_task_definition_arn" {
  name       = "/${local.name_prefix}/ecs_task_definition_arn"
  type       = "String"
  value      = aws_ecs_task_definition.task.arn
  tags       = local.common_tags
  depends_on = [aws_ecs_task_definition.task]
}