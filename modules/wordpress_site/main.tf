module "domain" {
  source                     = "./domain"
  domains                    = concat([var.wordpress_domain], var.redirect_subdomains)
  hosted_zone_id             = var.hosted_zone_id
  resource_name_prefix       = var.resource_name_prefix
  cloudfront_distribution_id = module.cloudfront.id
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

module "certificate" {
  providers = {
    aws = aws.us-east-1
  }
  source               = "./certificate"
  domain               = var.wordpress_domain
  hosted_zone          = var.hosted_zone_id
  resource_name_prefix = var.resource_name_prefix
  redirect_subdomains  = var.redirect_subdomains
}

module "cloudfront" {
  source               = "./cloudfront"
  acm_certificate_arn  = module.certificate.certificate_arn
  resource_name_prefix = var.resource_name_prefix
  wordpress_domain     = var.wordpress_domain
  wordpress_site_slug  = var.wordpress_site_slug
  default_domain       = var.lb_default_domain
  http_origin_header   = var.http_origin_header
  redirect_subdomains  = var.redirect_subdomains
  waf_id               = var.waf_id
}

module "listener_rule" {
  count                = length(var.redirect_subdomains)
  source               = "./listener_rule"
  redirect_subdomains  = var.redirect_subdomains
  listener_arn         = var.listener_arn
  resource_name_prefix = var.resource_name_prefix
  wordpress_domain     = var.wordpress_domain
}