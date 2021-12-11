data "aws_cloudfront_distribution" "this" {
  id = var.cloudfront_distribution_id
}

resource "aws_route53_record" "this" {
  count   = length(var.domains)
  zone_id = var.hosted_zone_id
  name    = var.domains[count.index]
  type    = "A"

  alias {
    name                   = data.aws_cloudfront_distribution.this.domain_name
    zone_id                = data.aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}