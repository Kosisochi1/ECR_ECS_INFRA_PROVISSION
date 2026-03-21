output "ecr_repositroy_url" {
  value = module.ecr.repo_url

}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}
