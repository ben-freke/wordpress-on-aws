output "vpc_id" {
  description = "The ID of the VPC that was created."
  value       = aws_vpc.this.id
}

output "subnets" {
  description = "A map of subnet lists."
  value       = module.subnets.ids
}

output "security_group_ids" {
  value = module.security_groups.ids
}