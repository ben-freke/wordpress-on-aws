variable "resource_name_prefix" {
  type        = string
  description = "The name to prefix to all created resources."
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "public_subnets" {
  type        = list(string)
  description = "A list of public subnets."
}