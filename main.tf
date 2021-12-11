######################
# --- Networking --- #
######################

# Sets up the networking configuration e.g. VPC, Subnets etc.

module "networking" {
  source               = "./modules/networking"
  resource_name_prefix = var.resource_name_prefix
  vpc_cidr             = var.vpc_cidr
}

####################
# --- Database --- #
####################

# Sets up the RDS MySQL Database for Wordpress

module "database" {
  source               = "./modules/database/db_instance"
  resource_name_prefix = var.resource_name_prefix
  security_group_ids   = module.networking.security_group_ids.database
  subnet_ids           = module.networking.subnets.database
}

###############
# --- EFS --- #
###############

# Sets up the Elastic File Storage configuration

module "storage" {
  source               = "./modules/storage"
  resource_name_prefix = var.resource_name_prefix
  subnet_ids           = module.networking.subnets.private
  security_group_ids   = module.networking.security_group_ids.efs
}

#########################
# --- Load Balancer --- #
#########################

# Sets up the central Application Load Balancer that handles all traffic.

module "load_balancer" {
  source               = "./modules/load_balancer"
  resource_name_prefix = var.resource_name_prefix
  security_group_ids   = module.networking.security_group_ids.alb
  subnet_ids           = module.networking.subnets.public
  core_hosted_zone     = var.core_hosted_zone
  default_domain       = var.default_domain
}

####################################
# --- Web Application Firewall --- #
####################################

module "waf" {
  source               = "./modules/waf"
  resource_name_prefix = var.resource_name_prefix
}

#########################
# --- Code Pipeline --- #
#########################

module "github_iam_user" {
  source               = "./modules/github_iam_user"
  resource_name_prefix = var.resource_name_prefix
}

###################
# --- Compute --- #
###################

module "compute" {
  source                      = "./modules/compute"
  database_host               = module.database.database_endpoint
  database_password_ssm_param = module.database.ssm_param
  efs_id                      = module.storage.efs_id
  resource_name_prefix        = var.resource_name_prefix
  security_groups             = module.networking.security_group_ids.compute
  subnets                     = module.networking.subnets.private
  target_group_arns           = module.load_balancer.target_group_arns
  docker_image                = var.docker_image
}

###########################
# --- Wordpress Sites --- #
###########################

module "website" {
  for_each             = var.website_configs
  source               = "./modules/wordpress_site"
  resource_name_prefix = var.resource_name_prefix
  lb_default_domain    = module.load_balancer.domain
  wordpress_site_slug  = "wordpress_site_slug"
  wordpress_domain     = "wordpress_domain"
  hosted_zone_id       = "hosted_zone_id"
  http_origin_header   = module.load_balancer.http_origin_header
  listener_arn         = module.load_balancer.listener_arn
  redirect_subdomains  = "redirect_subdomains"
  waf_id               = module.waf.id
}