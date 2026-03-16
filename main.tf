
data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true


  tags = {
    Name = "ecs-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}




resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "public-subnet-${count.index}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id

}


resource "aws_security_group" "ecs" {
  name   = "ecs-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.alb_sg.id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb_sg" {
  name   = "alb_sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_ecr_repository" "demo_repo" {
  name = var.app_name
  image_scanning_configuration {
    scan_on_push = true

  }

  force_delete = true



}



resource "aws_ecs_cluster" "demo_app_cluster" {
  name = "${var.app_name}-cluster"

}


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
resource "aws_iam_role" "ecs_demo_app_execution_role" {
  name = "${var.app_name}-execution-role"

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
  role       = aws_iam_role.ecs_demo_app_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_user_policy" "pass_role_policy" {
  name = "PassECSRole"
  user = "Kosi_user"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = ["arn:aws:iam::710271940761:role/much_todo_demo-role",
        "arn:aws:iam::710271940761:role/much_todo_demo-execution-role"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy_role" {
  role       = aws_iam_role.ecs_demo_app_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_ecs_task_definition" "demo_app_task" {
  family                   = var.app_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  # task_role_arn            = aws_iam_role.ecs_demo_app_task_role.arn
  # execution_role_arn       = aws_iam_role.ecs_demo_app_task_role.arn
  execution_role_arn = aws_iam_role.ecs_demo_app_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_demo_app_task_role.arn
  container_definitions = jsonencode([
    {
      name      = var.app_name
      image     = "${aws_ecr_repository.demo_repo.repository_url}:latest"
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
          valueFrom = "${aws_secretsmanager_secret.secret_manager.arn}:MONGO_URI::"
        },
        {
          name      = "JWT_SECRET_KEY"
          valueFrom = "${aws_secretsmanager_secret.secret_manager.arn}:JWT_SECRET_KEY::"
        },
        {
          name      = "DB_NAME"
          valueFrom = "${aws_secretsmanager_secret.secret_manager.arn}:DB_NAME::"
        },
        {
          name      = "LOG_LEVEL"
          valueFrom = "${aws_secretsmanager_secret.secret_manager.arn}:LOG_LEVEL::"
        },
        {
          name      = "LOG_FORMAT"
          valueFrom = "${aws_secretsmanager_secret.secret_manager.arn}:LOG_FORMAT::"
        },
        {
          name      = "INTEGRATION"
          valueFrom = "${aws_secretsmanager_secret.secret_manager.arn}:INTEGRATION::"
        },
        {
          name      = "JWT_EXPIRATION_HOURS"
          valueFrom = "${aws_secretsmanager_secret.secret_manager.arn}:JWT_EXPIRATION_HOURS::"
        },


      ]
    }
    ]



  )

}



resource "aws_kms_key" "secret-KEY" {

  description             = "kms key for much_to_do app"
  deletion_window_in_days = 7
  enable_key_rotation     = true

}

resource "aws_kms_alias" "secret_alias" {
  name          = "alias/${var.app_name}-key"
  target_key_id = aws_kms_key.secret-KEY.key_id

}
resource "aws_secretsmanager_secret" "secret_manager" {
  name        = var.app_name
  description = "storing all secret keys for much_to_do app"
  kms_key_id  = aws_kms_key.secret-KEY.key_id

}


resource "aws_secretsmanager_secret_version" "demo_app_secret_key" {

  secret_id = aws_secretsmanager_secret.secret_manager.id
  secret_string = jsonencode({
    MONGO_URI = var.mongo_uri,
    LOG_LEVEL = "DEBUG",
    DB_NAME   = "much_todo_db",

    # Log format: "json" or "text"
    LOG_FORMAT = "json",

    # --- Testing ---
    INTEGRATION          = true,
    JWT_SECRET_KEY       = var.jwt_secret_key,
    JWT_EXPIRATION_HOURS = 72
  })



}


resource "aws_iam_policy" "secret_key_policy" {
  name = "${var.app_name}-secrets-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets"
        ]
        Resource = aws_secretsmanager_secret.secret_manager.arn
        }, {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",

        ]
        Resource = aws_kms_key.secret-KEY.arn

      }
    ]
  })

}


resource "aws_iam_policy_attachment" "secret_attachment" {
  name       = "${var.app_name}-secret-attachment"
  roles      = [aws_iam_role.ecs_demo_app_task_role.name, aws_iam_role.ecs_demo_app_execution_role.name]
  policy_arn = aws_iam_policy.secret_key_policy.arn

}


resource "aws_ecs_service" "aap_service" {



  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.demo_app_cluster.id
  task_definition = aws_ecs_task_definition.demo_app_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = aws_security_group.ecs[*].id
    assign_public_ip = true


  }
  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = var.app_name
    container_port   = var.port
  }

  depends_on = [aws_lb_listener.http]
}
resource "aws_lb" "app_lb" {
  name               = "much-to-do-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_lb_target_group" "app_tg" {
  name        = "much-to-do-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id
  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2

  }

}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
