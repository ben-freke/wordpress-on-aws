###############################
# --- Private Route Table --- #
###############################

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id
}

resource "aws_route" "private_access" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  instance_id            = var.nat_instance_id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = var.private_subnets[count.index]
  route_table_id = aws_route_table.private.id
}

##############################
# --- Public Route Table --- #
##############################

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.internet_gateway_id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = var.public_subnets[count.index]
  route_table_id = aws_route_table.public.id
}