variable "resource_name_prefix" {
  type        = string
  description = "The name to prefix to all created resources."
}


variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "internet_gateway_id" {
  description = "The ID of the internet gateway."
  type        = string
}

variable "private_subnets" {
  type        = list(string)
  description = "A list of subnets to apply the private route table to."
}

variable "public_subnets" {
  type        = list(string)
  description = "A list of subnets to apply the public route table to."
}

variable "nat_instance_id" {
  type        = string
  description = "The ID of the NAT Gateway"
}