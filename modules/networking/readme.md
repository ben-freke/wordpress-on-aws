# Networking

This networking module provides the core networking for a typical web application, and is designed for use with Wordpress.
## VPC

The VPC has DNS Support and Hostnames enabled.

## VPC Flow Logging

VPC Flow Logging is enabled for the VPC. Flow logs are pumped to a CloudWatch log group.

# Subnets

Private and database subnets do not have access to the internet 
as there is no NAT Gateway in this setup in order to reduce costs.