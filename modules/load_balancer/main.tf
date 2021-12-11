data "aws_subnet" "this" { id = var.subnet_ids[0] }

#tfsec:ignore:aws-elbv2-alb-not-public
resource "aws_lb" "this" {
  name            = "${var.resource_name_prefix}-central-lb"
  internal        = false
  security_groups = var.security_group_ids
  subnets         = var.subnet_ids
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.this.arn
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "404"
    }
  }
}

resource "aws_acm_certificate" "this" {
  domain_name       = var.default_domain
  validation_method = "DNS"
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
  zone_id         = var.core_hosted_zone
}

resource "aws_route53_record" "root" {
  zone_id = var.core_hosted_zone
  name    = var.default_domain
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = false
  }
}

# Generate a randoms string to use as the origin id.
resource "random_string" "random" {
  length  = 32
  special = false
}

module "listener_rule" {
  source               = "./listener_rule"
  acm_certificate_arn  = aws_acm_certificate.this.arn
  http_origin_header   = random_string.random.result
  listener_arn         = aws_lb_listener.https.arn
  resource_name_prefix = var.resource_name_prefix
  vpc_id               = data.aws_subnet.this.vpc_id
}