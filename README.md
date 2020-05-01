# Sample Cloud Architectures Deployable to DigitalOcean
This repository is a collection of sample architectures using multiple 
[DigitalOcean](https://www.digitalocean.com/) products to produce production 
ready environments for code to be deployed. All architectures are deployed via
[Terraform](https://www.terraform.io/).

## Requirements
You will need the following to deploy the code within these repositories:

* A [DigitalOcean Account](https://cloud.digitalocean.com/projects). You will 
need to create an [API key](https://www.digitalocean.com/docs/apis-clis/api/create-personal-access-token/) in the [cloud dashboard](https://cloud.digitalocean.com/)

* Terrform [installed](https://www.terraform.io/downloads.html) in your 
developer environment. 

## Functional Architectures

* [01-minimal-vpc](https://github.com/Zelgius/terraform-sample-digitalocean-architectures/tree/master/01-minimal-vpc) - This is what I considered _bare bones_ VPC architecture.

## Work In Progress Architectures

* 02-minial-vpc-bastions-nat-gateway - An extension of minimal-vpc with
a NAT-gateway and multiple bastion hosts behind a load balancer
