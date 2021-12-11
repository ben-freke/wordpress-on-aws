variable "subnets" {
  type        = list(string)
  description = "A list of subnet IDs, one of which will be chosen to host the NAT instance."
}

variable "security_group_ids" {
  type        = list(string)
  description = "A list of security group IDs for the NAT Instance."
}