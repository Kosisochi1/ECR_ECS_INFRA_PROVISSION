resource "aws_iam_role" "ecs_demo_app_task_role" {
  name = "${var.app_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ecs_execution_role_attach" {
  role       = aws_iam_role.ecs_demo_app_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_user_policy" "pass_role_policy" {
  name = "PassECSRole"
  user = "Kosi_user"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = ["arn:aws:iam::710271940761:role/much_todo_demo-role"]
      }
    ]
  })
}

resource "aws_ecs_cluster" "demo_app_cluster" {
  name = "${var.app_name}-cluster"

}










resource "aws_ecs_task_definition" "demo_app_task" {
  family                   = var.app_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_demo_app_task_role.arn
  task_role_arn            = aws_iam_role.ecs_demo_app_task_role.arn
  container_definitions = jsonencode([
    {
      name      = var.app_name
      image     = "${var.repo_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = var.port
          hostPort      = var.port
          # protocol = "tcp"
        }
      ],
      secrets = [
        {
          name      = "MONGO_URI"
          valueFrom = "${var.secret_arn}:MONGO_URI::"
        },
        {
          name      = "JWT_SECRET_KEY"
          valueFrom = "${var.secret_arn}:JWT_SECRET_KEY::"
        },
        {
          name      = "DB_NAME"
          valueFrom = "${var.secret_arn}:DB_NAME::"
        },
        {
          name      = "LOG_LEVEL"
          valueFrom = "${var.secret_arn}:LOG_LEVEL::"
        },
        {
          name      = "LOG_FORMAT"
          valueFrom = "${var.secret_arn}:LOG_FORMAT::"
        },
        {
          name      = "INTEGRATION"
          valueFrom = "${var.secret_arn}:INTEGRATION::"
        },
        {
          name      = "JWT_EXPIRATION_HOURS"
          valueFrom = "${var.secret_arn}:JWT_EXPIRATION_HOURS::"
        },


      ]
    }
    ]



  )

}



resource "aws_ecs_service" "aap_service" {



  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.demo_app_cluster.id
  task_definition = aws_ecs_task_definition.demo_app_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.subnets
    security_groups  = [var.ecs_sg]
    assign_public_ip = true


  }
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.app_name
    container_port   = var.port
  }

  depends_on = [var.listener_http]
}
