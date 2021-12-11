data "aws_region" "current" {}

resource "aws_efs_access_point" "this" {
  file_system_id = var.file_system_id
  root_directory {
    path = "/wordpress"
    creation_info {
      owner_gid   = 82
      owner_uid   = 82
      permissions = "770"
    }
  }
}

#tfsec:ignore:aws-cloudwatch-log-group-customer-key
resource "aws_cloudwatch_log_group" "this" {
  name              = "${var.resource_name_prefix}/ecs"
  retention_in_days = 365
}

resource "aws_ecs_service" "this" {
  name                   = "${var.resource_name_prefix}-service"
  task_definition        = aws_ecs_task_definition.this.arn
  desired_count          = 1
  cluster                = var.cluster_id
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = false
    security_groups  = var.security_group_ids
  }

  dynamic "load_balancer" {
    for_each = var.target_group_arns
    content {
      container_name   = "${var.resource_name_prefix}-container"
      container_port   = 80
      target_group_arn = load_balancer.value
    }
  }

  health_check_grace_period_seconds = 3600
}

resource "aws_ecs_task_definition" "this" {
  family = "${var.resource_name_prefix}-tasks"
  container_definitions = jsonencode([
    {
      name      = "${var.resource_name_prefix}-container"
      image     = var.docker_image
      essential = true
      portMappings = [{
        containerPort = 80
        hostPort      = 80
      }]
      secrets = [
        {
          name      = "WORDPRESS_DB_PASSWORD"
          valueFrom = var.db_config.password_ssm_param_arn
        }
      ]
      environment = [
        {
          name  = "WORDPRESS_DB_HOST"
          value = var.db_config.host
        },
        {
          name  = "WORDPRESS_CONFIG_EXTRA"
          value = file("${path.root}/resources/configs/multisite_config.txt")
        },
        {
          name  = "WORDPRESS_DB_USER"
          value = var.db_config.user
        },
        {
          name  = "WORDPRESS_DB_NAME"
          value = var.db_config.name
        },
      ],
      mountPoints = [
        {
          containerPath = "/var/www/html"
          sourceVolume  = "efs"
        }
      ]
      ephemeralStorage : {
        sizeInGiB : 8
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "${var.resource_name_prefix}-container"
        }
      }
    },
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 1024
  execution_role_arn       = var.iam_role_arn
  task_role_arn            = var.iam_role_arn
  volume {
    name = "efs"
    efs_volume_configuration {
      file_system_id     = var.file_system_id
      transit_encryption = "ENABLED"
      root_directory     = "/"
      authorization_config {
        access_point_id = aws_efs_access_point.this.id
      }
    }
  }
}