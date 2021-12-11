variable "resource_name_prefix" {
  type        = string
  description = "The name to prefix to all created resources."
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs within which to mount the EFS. Only one will be chosen at random."
}

variable "security_group_ids" {
  type        = list(string)
  description = "A list of security group IDs."
}