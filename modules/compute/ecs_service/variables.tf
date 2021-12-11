variable "file_system_id" {
  type        = string
  description = "The ID of the EFS File System."
}

variable "resource_name_prefix" {
  type        = string
  description = "The name to prefix to all created resources."
}

variable "cluster_id" {
  type        = string
  description = "The ID of the ECS Cluster within which the service will reside."
}

variable "subnet_ids" {
  type        = list(string)
  description = "The list of Subnet IDs within which to deploy the task."
}

variable "security_group_ids" {
  type        = list(string)
  description = "A list of security group IDs for the task."
}

variable "docker_image" {
  type        = string
  description = "The docker image for the service"
}

variable "iam_role_arn" {
  type        = string
  description = "The ARN of the IAM Role to attach to the instance."
}

variable "db_config" {
  type = object({
    password_ssm_param_arn = string
    host                   = string
    user                   = string
    name                   = string
  })
}

variable "target_group_arns" {
  type        = list(string)
  description = "The ARNs of the Load Balancer Target Groups."
}