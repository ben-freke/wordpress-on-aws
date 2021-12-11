data "aws_availability_zones" "this" {}
data "aws_vpc" "this" { id = var.vpc_id }

#######################
# --- Local Setup --- #
#######################

# The local variables here are used to calculate the subnet masks based on the VPC CIDR Block and
# the number of subnets required. In order to do this, some maths is required.
# For example, if you have a Web, Application and Database subnet the subnets_per_az would be 3.

locals {
  az_count       = length(data.aws_availability_zones.this.names)
  vpc_cidr_mask  = split("/", data.aws_vpc.this.cidr_block)[1]
  subnets_per_az = 3
  newbits        = 32 - (floor(log(pow(2, 32 - local.vpc_cidr_mask) / (local.az_count * local.subnets_per_az), 2))) - local.vpc_cidr_mask
}

resource "aws_subnet" "private" {
  count                   = local.az_count
  vpc_id                  = var.vpc_id
  cidr_block              = cidrsubnet(data.aws_vpc.this.cidr_block, local.newbits, count.index + (0 * local.subnets_per_az))
  availability_zone       = data.aws_availability_zones.this.names[count.index]
  map_public_ip_on_launch = false
  tags                    = { Name = "${var.resource_name_prefix}-private-${data.aws_availability_zones.this.names[count.index]}" }
}

resource "aws_subnet" "database" {
  count                   = local.az_count
  vpc_id                  = var.vpc_id
  cidr_block              = cidrsubnet(data.aws_vpc.this.cidr_block, local.newbits, count.index + (1 * local.subnets_per_az))
  availability_zone       = data.aws_availability_zones.this.names[count.index]
  map_public_ip_on_launch = false
  tags                    = { Name = "${var.resource_name_prefix}-database-${data.aws_availability_zones.this.names[count.index]}" }
}

resource "aws_subnet" "public" {
  count                   = local.az_count
  vpc_id                  = var.vpc_id
  cidr_block              = cidrsubnet(data.aws_vpc.this.cidr_block, local.newbits, count.index + (2 * local.subnets_per_az))
  availability_zone       = data.aws_availability_zones.this.names[count.index]
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.resource_name_prefix}-public-${data.aws_availability_zones.this.names[count.index]}" }
}

