output "ids" {
  value = {
    private  = aws_subnet.private.*.id
    database = aws_subnet.database.*.id
    public   = aws_subnet.public.*.id
  }
  description = "A map of lists of each of the created subnets."
}