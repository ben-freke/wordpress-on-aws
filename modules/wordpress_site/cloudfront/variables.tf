variable "wordpress_site_slug" {
  type        = string
  description = "The site slug for the wordpress site."
}

variable "resource_name_prefix" {
  type        = string
  description = "The name to prefix to all created resources."
}

variable "wordpress_domain" {
  type        = string
  description = "The domain for the wordpress site."
}

variable "default_domain" {
  type        = string
  description = "The default domain for the load balancer."
}

variable "acm_certificate_arn" {
  type        = string
  description = "The certificate ARN of the ACM certificate."
}

variable "http_origin_header" {
  type        = string
  description = "The HTTP Origin Header to restrict access to the load balancer."
}

variable "redirect_subdomains" {
  type        = list(string)
  description = "Domains which should be redirected to the wordpress domain."
  default     = []
}

variable "waf_id" {
  type        = string
  description = "The ID of the WAF to attach to CloudFront."
}