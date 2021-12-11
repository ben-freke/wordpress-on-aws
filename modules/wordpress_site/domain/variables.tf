variable "resource_name_prefix" {
  type        = string
  description = "The name to prefix to all created resources."
}

variable "hosted_zone_id" {
  type        = string
  description = "The ID of the Route 53 Hosted Zone."
}

variable "domains" {
  type        = list(string)
  description = "The list domains of the wordpress site."
}

variable "cloudfront_distribution_id" {
  type        = string
  description = "The ID of the AWS CloudFront Distribution."
}