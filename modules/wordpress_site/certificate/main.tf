terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

resource "aws_acm_certificate" "this" {
  domain_name               = var.domain
  validation_method         = "DNS"
  subject_alternative_names = var.redirect_subdomains
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "this" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.hosted_zone
}

resource "time_sleep" "this" {
  create_duration = "5m"
  depends_on      = [aws_acm_certificate.this, aws_route53_record.this]
  triggers = {
    acm_arn = aws_acm_certificate.this.arn
  }
}