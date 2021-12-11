data "aws_vpc" "this" {
  id = var.vpc_id
}

##########################
### RDS Security Group ###
##########################

# Create the RDS Security Group
resource "aws_security_group" "rds" {
  name        = "${var.resource_name_prefix}-rds-sg"
  description = "The security group for the RDS Database."
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "rds_sql_inbound" {
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.compute.id
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "Allows SQL inbound from the defined security group."
}

resource "aws_security_group_rule" "rds_sql_inbound_pipeline" {
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.pipeline.id
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "Allows SQL inbound from the defined security group."
}

resource "aws_security_group" "compute" {
  name        = "${var.resource_name_prefix}-compute-sg"
  description = "The security group attached to EC2 instances."
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "compute_http_inbound" {
  security_group_id        = aws_security_group.compute.id
  source_security_group_id = aws_security_group.alb.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "Allows HTTP inbound from the defined security group."
}

resource "aws_security_group_rule" "compute_efs_inbound" {
  security_group_id        = aws_security_group.compute.id
  source_security_group_id = aws_security_group.efs.id
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "Allows EFS inbound from the defined security group."
}

resource "aws_security_group_rule" "compute_nfs_outbound" {
  security_group_id        = aws_security_group.compute.id
  source_security_group_id = aws_security_group.efs.id
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  type                     = "egress"
  description              = "Allows NFS outbound from the defined security group."
}

resource "aws_security_group_rule" "compute_sql_outbound" {
  security_group_id        = aws_security_group.compute.id
  source_security_group_id = aws_security_group.rds.id
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  type                     = "egress"
  description              = "Allows SQL outbound from the defined security group."
}

#tfsec:ignore:aws-vpc-no-public-egress-sgr
resource "aws_security_group_rule" "compute_http_outbound" {
  security_group_id = aws_security_group.compute.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  type              = "egress"
  description       = "Allows HTTP outbound from the defined security group."
}
#tfsec:ignore:aws-vpc-no-public-egress-sgr
resource "aws_security_group_rule" "compute_https_outbound" {
  security_group_id = aws_security_group.compute.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  type              = "egress"
  description       = "Allows HTTPS outbound from the defined security group."
}

resource "aws_security_group" "efs" {
  name        = "${var.resource_name_prefix}-efs-sg"
  description = "The security group attached to EFS mount targets."
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "efs_nfs_inbound" {
  security_group_id        = aws_security_group.efs.id
  source_security_group_id = aws_security_group.compute.id
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "Allows NFS inbound from the defined security group."
}

resource "aws_security_group" "alb" {
  name        = "${var.resource_name_prefix}-alb-sg"
  description = "The security group attached to ALB."
  vpc_id      = var.vpc_id
}
#tfsec:ignore:aws-vpc-no-public-ingress-sgr
resource "aws_security_group_rule" "alb_https_inbound" {
  security_group_id = aws_security_group.alb.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  type              = "ingress"
  description       = "Allows HTTPS inbound from the defined CIDRs."
}

resource "aws_security_group_rule" "alb_http_outbound" {
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.compute.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  type                     = "egress"
  description              = "Allows HTTP outbound to the defined security groups."
}

resource "aws_security_group" "pipeline" {
  name        = "${var.resource_name_prefix}-pipeline-sg"
  description = "The security group attached to CodePipeline."
  vpc_id      = var.vpc_id
}
#tfsec:ignore:aws-vpc-no-public-egress-sgr
resource "aws_security_group_rule" "pipeline_http_outbound" {
  security_group_id = aws_security_group.pipeline.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  type              = "egress"
  description       = "Allows HTTP outbound to the defined security groups."
}

#tfsec:ignore:aws-vpc-no-public-egress-sgr
resource "aws_security_group_rule" "pipeline_https_outbound" {
  security_group_id = aws_security_group.pipeline.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  type              = "egress"
  description       = "Allows HTTP outbound to the defined security groups."
}

resource "aws_security_group_rule" "pipeline_mysql_outbound" {
  security_group_id        = aws_security_group.pipeline.id
  source_security_group_id = aws_security_group.rds.id
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  type                     = "egress"
  description              = "Allows MySQL outbound to the defined security groups."
}

resource "aws_security_group" "nat_instance" {
  name        = "${var.resource_name_prefix}-nat-instance-sg"
  description = "The security group attached to CodePipeline."
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "nat_instance_inbound" {
  security_group_id = aws_security_group.nat_instance.id
  cidr_blocks       = [data.aws_vpc.this.cidr_block]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "ingress"
  description       = "Allow NAT Instance Inbound Traffic from the VPC."
}

#tfsec:ignore:aws-vpc-no-public-egress-sgr
resource "aws_security_group_rule" "nat_instance_outbound" {
  security_group_id = aws_security_group.nat_instance.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "egress"
  description       = "Allows all outbound traffic from the NAT Instance."
}
