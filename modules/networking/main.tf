# Get the availablity zones to distribute the subnets and security groups.
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

module "security_groups" {
  source = "./security_groups"

  resource_name_prefix = var.resource_name_prefix
  vpc_id               = aws_vpc.this.id
}

module "vpc_flow_logging" {
  source = "./vpc_flow_logs"

  resource_name_prefix = var.resource_name_prefix
  vpc_id               = aws_vpc.this.id
}

module "route_tables" {
  source = "./route_tables"

  internet_gateway_id  = module.gateways.internet_gateway_id
  resource_name_prefix = var.resource_name_prefix
  vpc_id               = aws_vpc.this.id
  private_subnets      = concat(module.subnets.ids.private, module.subnets.ids.database)
  public_subnets       = module.subnets.ids.public
  nat_instance_id      = module.nat_instance.instance_id
}

module "subnets" {
  source = "./subnets"

  resource_name_prefix = var.resource_name_prefix
  vpc_id               = aws_vpc.this.id
}

module "gateways" {
  source = "./gateways"

  resource_name_prefix = var.resource_name_prefix
  vpc_id               = aws_vpc.this.id
  public_subnets       = module.subnets.ids.public
}

module "nat_instance" {
  source             = "./nat_instance"
  subnets            = module.subnets.ids.public
  security_group_ids = module.security_groups.ids.nat_instance
}