variable "resource_name_prefix" {
  type        = string
  description = "The name to prefix to all created resources."
}

variable "environment" {
  type        = string
  description = "The environment into which this Terraform code is being deployed"
  default     = "dev"
}

variable "subnet_cidr_ranges" {
  description = "A map of the lists of CIDR ranges for the subnets."
  type = object({
    public   = list(string)
    private  = list(string)
    database = list(string)
  })
  default = {
    public   = ["10.254.0.0/24", "10.254.1.0/24", "10.254.2.0/24"]
    private  = ["10.254.3.0/24", "10.254.4.0/24", "10.254.5.0/24"]
    database = ["10.254.6.0/24", "10.254.7.0/24", "10.254.8.0/24"]
  }
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}