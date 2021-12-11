data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]
}
#tfsec:ignore:aws-autoscaling-no-public-ip tfsec:ignore:aws-ec2-enforce-http-token-imds
resource "aws_instance" "this" {
  ami                         = data.aws_ami.this.id
  instance_type               = "t3.nano"
  source_dest_check           = false
  associate_public_ip_address = true
  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = 8
    volume_type           = "gp2"
  }
  subnet_id              = var.subnets[0]
  vpc_security_group_ids = var.security_group_ids
  user_data_base64       = base64encode(file("${path.root}/resources/scripts/nat_setup.sh"))
  tags = {
    Name = "NAT Instance"
  }
}