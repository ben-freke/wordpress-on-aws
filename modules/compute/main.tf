data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

#tfsec:ignore:aws-ecs-enable-container-insight
resource "aws_ecs_cluster" "this" {
  name = "${var.resource_name_prefix}-wordpress-cluster"
}

module "iam" {
  source               = "./iam"
  resource_name_prefix = var.resource_name_prefix
  ssm_param_arn        = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.database_password_ssm_param}"
}

module "ecs" {
  source     = "./ecs_service"
  cluster_id = aws_ecs_cluster.this.id
  db_config = {
    password_ssm_param_arn = var.database_password_ssm_param
    host                   = var.database_host
    user                   = "wordpress_usr"
    name                   = "wordpress"
  }
  docker_image         = var.docker_image
  file_system_id       = var.efs_id
  iam_role_arn         = module.iam.arn
  resource_name_prefix = var.resource_name_prefix
  security_group_ids   = var.security_groups
  subnet_ids           = var.subnets
  target_group_arns    = var.target_group_arns
}