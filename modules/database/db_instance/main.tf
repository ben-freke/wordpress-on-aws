resource "random_password" "password" {
  length           = 40
  special          = true
  min_special      = 5
  override_special = "!#$%^&*()-_=+[]{}<>:?"
  keepers = {
    pass_version = 1
  }
}

#tfsec:ignore:aws-rds-backup-retention-specified
resource "aws_db_instance" "this" {

  # Instance Setup
  allocated_storage     = 10
  max_allocated_storage = 100
  instance_class        = "db.t3.micro" # https://aws.amazon.com/rds/sqlserver/instance-types/

  # Database Configuration

  engine         = "mysql"
  engine_version = "8.0"

  # Security Setup

  username                        = "admin"
  password                        = random_password.password.result
  allow_major_version_upgrade     = false
  auto_minor_version_upgrade      = true
  enabled_cloudwatch_logs_exports = ["error", "general"]
  vpc_security_group_ids          = var.security_group_ids

  # Networking Setup
  db_subnet_group_name = aws_db_subnet_group.this.name
  skip_final_snapshot  = true
  storage_encrypted    = true

  #TODO Need to look at backup configurations.

}

resource "aws_db_subnet_group" "this" {
  name       = "${var.resource_name_prefix}-db-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_ssm_parameter" "admin" {
  name  = "${var.resource_name_prefix}-admin-db-creds"
  type  = "SecureString"
  value = random_password.password.result
}

module "database" {
  source                  = "../database"
  database_admin_password = random_password.password.result
  database_admin_user     = "admin"
  database_endpoint       = aws_db_instance.this.endpoint
  database_name           = "wordpress"
}

resource "aws_ssm_parameter" "client" {
  name  = "${var.resource_name_prefix}-client-db-creds"
  type  = "SecureString"
  value = module.database.database_password
}