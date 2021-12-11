variable "resource_name_prefix" {
  type        = string
  description = "The name to prefix to all created resources."
}

variable "listener_arn" {
  type        = string
  description = "The ARN of the Load Balancer Listener."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC."
}

variable "acm_certificate_arn" {
  type        = string
  description = "The ARN of the ACM certificate."
}

variable "http_origin_header" {
  type        = string
  description = "The HTTP Origin Header to restrict access to the load balancer."
}