variable "database_endpoint" {
  type        = string
  description = "The database endpoint."
}

variable "database_name" {
  type        = string
  description = "The name of the database to be created."
}

variable "database_admin_password" {
  type        = string
  description = "The admin password for the database."
}

variable "database_admin_user" {
  type        = string
  description = "The admin username for the database."
}