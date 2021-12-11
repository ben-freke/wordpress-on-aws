output "route_tables" {
  description = "A map of IDs for the created route tables."
  value = {
    private = aws_route_table.private.id
    public  = aws_route_table.public.id
  }
}