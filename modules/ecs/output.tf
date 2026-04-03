output "task_role_name" {
  value = aws_iam_role.ecs_demo_app_task_role.name

}

output "task_role" {
  value = aws_iam_role.ecs_task_role.name

}
output "cluster_name" {
  value = aws_ecs_cluster.demo_app_cluster.name

}

output "task_definition_json" {
  value = local.ecs_task_definition_json

}


