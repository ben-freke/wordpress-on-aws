# Configure the MySQL provider
terraform {
  required_providers {
    mysql = {
      source  = "petoju/mysql"
      version = "3.0.6"
    }
  }
}
provider "mysql" {
  endpoint = var.database_endpoint
  username = var.database_admin_user
  password = var.database_admin_password
}

resource "random_password" "this" {
  length  = 32
  special = false
}

resource "mysql_database" "this" {
  name = var.database_name
}

resource "mysql_user" "this" {
  user               = "${var.database_name}_usr"
  host               = "%"
  plaintext_password = random_password.this.result
}

resource "mysql_grant" "this" {
  user       = mysql_user.this.user
  host       = mysql_user.this.host
  database   = mysql_database.this.name
  privileges = ["SELECT", "INSERT", "UPDATE", "CREATE", "ALTER", "DELETE", "DROP", "INDEX"]
}