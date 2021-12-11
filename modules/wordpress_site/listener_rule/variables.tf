variable "resource_name_prefix" {
  type        = string
  description = "The name to prefix to all created resources."
}

variable "listener_arn" {
  type        = string
  description = "The ARN of the Load Balancer Listener."
}

variable "redirect_subdomains" {
  type        = list(string)
  description = "Domains which should be redirected to the wordpress domain."
  default     = []
}

variable "wordpress_domain" {
  type        = string
  description = "The wordpress domain."
}