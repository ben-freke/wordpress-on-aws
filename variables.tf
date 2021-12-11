variable "resource_name_prefix" {
  type        = string
  description = "The resource to prefix resources with."
}

variable "region" {
  type        = string
  description = "The region into which the Terraform Configuration is being deployed."
}

variable "environment" {
  type        = string
  description = "The environment in which the configuration is being deployed."
}

variable "core_hosted_zone" {
  type        = string
  description = "The hosted zone for the default certificate."
}

variable "default_domain" {
  type        = string
  description = "The domain for the default certificate."
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR to create the VPC in."
}

variable "website_configs" {
  type = list(object({
    site_slug           = string
    domain              = string
    hosted_zone_id      = string
    redirect_subdomains = list(string)
  }))
  description = "A list of wordpress sites to create."
}

variable "docker_image" {
  type        = string
  description = "The docker image for the service"
}