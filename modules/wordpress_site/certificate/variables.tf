variable "resource_name_prefix" {
  type        = string
  description = "The name to prefix to all created resources."
}

variable "hosted_zone" {
  type        = string
  description = "The hosted zone for the default certificate."
}

variable "domain" {
  type        = string
  description = "The domain for the default certificate."
}

variable "redirect_subdomains" {
  type        = list(string)
  description = "Domains which should be redirected to the wordpress domain."
  default     = []
}