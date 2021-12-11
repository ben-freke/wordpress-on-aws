variable "resource_name_prefix" {
  type        = string
  description = "The name to prefix to all created resources."
}

variable "environment" {
  type        = string
  description = "The environment into which this Terraform code is being deployed"
  default     = "dev"
}


variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "inbound_cidr_blocks" {
  type        = list(string)
  description = "The IP CIDR ranges to allow inbound connections to your Atlassian stack."
  default     = ["0.0.0.0/0"]
}