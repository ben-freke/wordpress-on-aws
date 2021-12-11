resource "aws_lb_listener_rule" "this" {
  listener_arn = var.listener_arn
  action {
    type = "redirect"
    redirect {
      status_code = "HTTP_301"
      host        = var.wordpress_domain
    }
  }
  condition {
    host_header {
      values = var.redirect_subdomains
    }
  }
}