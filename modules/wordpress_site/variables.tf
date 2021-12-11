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

variable "redirect_subdomains" {
  type        = list(string)
  description = "Domains which should be redirected to the wordpress domain."
  default     = []
}

variable "hosted_zone_id" {
  type        = string
  description = "The hosted zone ID for the website."
}

variable "lb_default_domain" {
  type        = string
  description = "The default domain for the load balancer."
}

variable "http_origin_header" {
  type        = string
  description = "The randomly generate string used to verify CloudFront's origin."
}

variable "listener_arn" {
  type        = string
  description = "The ARN of the Load Balancer Listener."
}

variable "waf_id" {
  type        = string
  description = "The ID of the WAF to attach to CloudFront."
}