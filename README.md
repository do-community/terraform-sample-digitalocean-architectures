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

* [01-minimal-web-db-stack](https://github.com/Zelgius/terraform-sample-digitalocean-architectures/tree/master/01-minimal-web-db-stack) - This architecture stands up the traditional architecture for a LEP* Stack 
(Linux, Nginx, Postgres, Web Tech). The webserver and database can easily be 
changed to fit what you require in the terraform files. This is a _basic_ VPC 
based architecture. See the README in the directory for more information.

## Work In Progress Architectures

* 02-minial-vpc-bastions-nat-gateway - An extension of minimal-web-db-stack with
a NAT-gateway and multiple bastion hosts behind a load balancer.
