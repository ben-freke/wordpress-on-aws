output "certificate_arn" {
  value = time_sleep.this.triggers.acm_arn
}