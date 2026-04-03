output "ecr_repositroy_url" {
  value = module.ecr.repo_url

}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}


# output "s3_bucket_name" {
#   value = module.s3_storage.task_def_s3_path

# }

output "json" {
  value = module.s3_storage.task_def

}


output "alb_dns" {
  value = module.alb.name

}
