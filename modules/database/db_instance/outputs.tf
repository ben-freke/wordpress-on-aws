output "database_password" {
  value = random_password.password.result
}

output "database_username" {
  value = aws_db_instance.this.username
}

output "database_endpoint" {
  value = aws_db_instance.this.address
}

output "database_parameters" {
  value = {
    endpoint = aws_db_instance.this.endpoint
    username = aws_db_instance.this.username
    password = random_password.password.result
  }
}

output "ssm_param" {
  value = aws_ssm_parameter.client.arn
}