# Output Jump Boxe DNS Name
output "jump_box_dns" {
  value = aws_instance.jump_box.private_dns
}

# Output Jump Box Private IP
output "admin_private_ip" {
  value = aws_instance.jump_box.private_ip
}

# Output Jump Box ID
output "jump_box_id" {
  value = aws_instance.jump_box.id
}

# # Output ECS Cluster ARN
# output "ecs_cluster_arn" {
#   value = aws_ecs_cluster.ecs_cluster.arn
# }

# # Output ECS Cluster ID
# output "ecs_cluster_id" {
#   value = aws_ecs_cluster.ecs_cluster.id
# }
