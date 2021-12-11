variable "resource_name_prefix" {
  type        = string
  description = "The name to prefix to all created resources."
}

variable "vpc_cidr" {
  description = "The first two octets of the VPC CIDR range (e.g. '10.0'). Must make a valid /16 range."
  type        = string
}