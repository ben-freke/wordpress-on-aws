# Wordpress on AWS

This repository contains the Terraform to deploy Wordpress on AWS. It uses ECS, RDS, EFS and CloudFront.

## Documentation

The architecture of this is documented [on my website](https://www.benfreke.org).

## Usage

To use this, you'll need be running on something that can make SQL commands to the database. As such, deployment is typically run in two steps:

1. Deploy the networking configuration;
2. From _within_ the network, apply the remaining changes.

For example:

```bash
terraform init --backend-config=config/[env]/backend.conf
terraform apply --var-file=config/[env]/variables.tfvars --target module.networking
terraform apply --var-file=config/[env]/variables.tfvars
```

## GitHub Actions

There are some GitHub action files which deploy changes automatically. 

In my deployment, I use self-hosted runners which run from inside of the VPC deployed by this configuration.