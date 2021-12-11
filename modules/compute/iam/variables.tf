variable "resource_name_prefix" {
  type        = string
  description = "The name to prefix to all created resources."
}

variable "ssm_param_arn" {
  type        = string
  description = "The ARN of the SSM Parameter."
}