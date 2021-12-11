output "ids" {
  value = {
    database     = [aws_security_group.rds.id]
    compute      = [aws_security_group.compute.id]
    efs          = [aws_security_group.efs.id]
    alb          = [aws_security_group.alb.id]
    pipeline     = [aws_security_group.pipeline.id]
    nat_instance = [aws_security_group.nat_instance.id]
  }
  description = "A map of lists of security group IDs."
}
