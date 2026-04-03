




module "vpc" {
  source = "./modules/vpc"

}


module "sg" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id


}

module "ecr" {
  source   = "./modules/ecr"
  app_name = var.app_name
}


module "alb" {
  source  = "./modules/alb"
  vpc_id  = module.vpc.vpc_id
  alb_sg  = module.sg.alb_sg
  subnets = module.vpc.public_subnets



}


module "secrets" {
  source         = "./modules/secrets"
  app_name       = var.app_name
  mongo_uri      = var.mongo_uri
  jwt_secret_key = var.jwt_secret_key
  task_role      = module.ecs.task_role_name




}


module "ecs" {
  source           = "./modules/ecs"
  app_name         = var.app_name
  cpu              = var.cpu
  memory           = var.memory
  port             = var.port
  repo_url         = module.ecr.repo_url
  subnets          = module.vpc.public_subnets
  ecs_sg           = module.sg.ecs_sg
  target_group_arn = module.alb.target_group_arn
  secret_arn       = module.secrets.secret_arn
  listener_http    = module.alb
  secret_policy    = module.secrets.secret_policy




}
module "s3_storage" {
  source                 = "./modules/s3_storage"
  task_definition_bucket = var.task_definition_bucket
  local_content          = module.ecs.task_definition_json
  s3_key                 = var.s3_key


}






# resource "aws_iam_role" "ecs_demo_app_execution_role" {
#   name = "${var.app_name}-execution-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "ecs-tasks.amazonaws.com"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }




# resource "aws_iam_role_policy_attachment" "ecs_task_policy_role" {
#   role       = aws_iam_role.ecs_demo_app_task_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }

















