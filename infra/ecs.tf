module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "5.2.2"

  cluster_name = var.ambiente

  cluster_configuration = {

    "name" : "containerInsights",
    "value" : "enabled"

  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
      }
    }
  }

  tags = {
    Environment = "Development"
  }
}


resource "aws_ecs_task_definition" "Django-API" {
  family                   = "Django-API"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256 #0.25 vCPU
  memory                   = 512 # 0.5 GB
  task_role_arn            = aws_iam_role.cargo.arn
  container_definitions = jsonencode(
    [
      {
        "name"      = "producao"
        "image"     = "028574230512.dkr.ecr.us-west-2.amazonaws.com/producao:v1"
        "cpu"       = 256
        "memory"    = 512
        "essential" = true
        "portMappings" = [
          {
            "containerPort" = 8000
            "hostPort"      = 8000
          }
        ]
      }
  ])
}



resource "aws_ecs_service" "Django-API" {
  name            = "Django-API"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.Django-API.arn
  desired_count   = 3

  load_balancer {
    target_group_arn = aws_lb_target_group.ip-alvo.arn
    container_name   = "producao"
    container_port   = 8000
  }

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.privado.id]
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
  }


}
