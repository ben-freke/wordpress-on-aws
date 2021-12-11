variable "resource_name_prefix" {
  type        = string
  description = "The name to prefix to all created resources."
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of Subnet IDs for the database."
}

variable "security_group_ids" {
  type        = list(string)
  description = "A list of Security Group IDs for the subnets."
}

variable "core_hosted_zone" {
  type        = string
  description = "The hosted zone for the default certificate."
}

variable "default_domain" {
  type        = string
  description = "The domain for the default certificate."
}