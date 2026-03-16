output "ecr_repositroy_url" {
  value = aws_ecr_repository.demo_repo.repository_url

}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.demo_app_cluster
}
