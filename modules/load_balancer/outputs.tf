output "load_balancer_arn" {
  value = aws_lb.this.arn
}

output "listener_arn" {
  value = aws_lb_listener.https.arn
}

output "domain" {
  value = var.default_domain
}

output "http_origin_header" {
  value = random_string.random.result
}

output "target_group_arns" {
  value = [module.listener_rule.target_group_arn]
}