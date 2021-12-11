resource "aws_lb_target_group" "this" {
  name        = "${var.resource_name_prefix}-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    enabled  = true
    matcher  = "200-499"
    path     = "/"
    protocol = "HTTP"
    timeout  = 10
  }
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = var.listener_arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
  condition {
    http_header {
      http_header_name = "cf-origin-header-value"
      values           = [var.http_origin_header]
    }
  }
}

resource "aws_lb_listener_certificate" "this" {
  certificate_arn = var.acm_certificate_arn
  listener_arn    = var.listener_arn
}
