variable "security_groups" {
  type        = list(string)
  description = "A list of security group IDs to attach to the instances."
}

variable "subnets" {
  type        = list(string)
  description = "A list of subnets to create the instances in."
}

variable "resource_name_prefix" {
  type        = string
  description = "The name to prefix to all created resources."
}

variable "efs_id" {
  type        = string
  description = "The ID the EFS storage."
}

variable "database_host" {
  type        = string
  description = "The database host."
}

variable "database_password_ssm_param" {
  type        = string
  description = "The database password SSM parameter name."
}

variable "target_group_arns" {
  type        = list(string)
  description = "The ARNs of the Target Groups."
}

variable "docker_image" {
  type        = string
  description = "The docker image for the service"
}