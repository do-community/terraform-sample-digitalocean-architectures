# Minimal VPC
The purpose of this directory is to provide a bare bones, production ready 
environment for common web architectures that require a database. The database
is loosely coupled for ease of removal if deemed unnecessary.

## Overview
This directory provides the necessary Terraform files to create a minimal VPC
architecture. In this architecture HTTPS traffic directed at a fully qualified 
domain name, such as fun.egger.codes, is directed to a Load Balancer which then
terminates SSL, forwarding the traffic internally across HTTP to a variable 
number of web servers (in this example, 3) isolated from the public internet 
within a Virtual Private Cloud (VPC). All of these web servers have access to a 
Postgres database, which is also isolated within the same VPC. A bastion host,
also known as a jump box, will also be created within this VPC to allow for
`ssh` access to the webservers. All webservers are configured to allow outbound
traffic across ports UDP 53 (DNS), TCP 80 (HTTP), TCP 443 (HTTPS), and ICMP 
(ping). This is to allow the servers to install packages from package managers
and test connections. This access can be disabled from within the terraform
files.

## Architecture Diagram
Below is a diagram representing the architecture that is produced by executing
the Terraform files in this directory. 

```
                          |                                                   
                        https                                                
                          |                                                   
                          v                                                    
                +--------------------+                                        
                |    Load Balancer   |                                        
   +----------------------------------------------------+                          
   |            |                    |                  |                     
   |            +--------------------+                  |                     
   |                     |                              |                     
   |                     |                              |                     
   |                    http                +---------+ |                     
   |                     |                  |         | |                     
   |                     |                  |         | |                     
   |                     +-------SSH--------| Bastion |<--------SSH-------    
   |                     |                  |         | |                     
   |                     |                  |         | |                     
   |                     |                  +---------+ |                     
   |          +----------+---------+                    |                     
   |          |          |         |                    |                     
   |          v          v         v                    |                     
   |      +-------+  +-------+  +-------+               |                     
   |      |  web  |  |  web  |  |  web  |               |                     
   |      +---+---+  +---+---+  +---+---+               |                     
   |          |          |          |                   |                     
   |          |          v          |                   |                     
   |          |     +----------+    |                   |                     
   |          |     |          |    |                   |                     
   |          +---->| database |<---+                   |                     
   |                |          |                        |                     
   |                +----------+                        |                     
   +----------------------------------------------------+  
```
## Detailed Explanation
Below are some explanations and guides on topics related to the architecture. 

### What is the Purpose of a VPC?
A Virtual Private Cloud, or VPC, is used to isolate resources from the public
internet. By placing droplets within an isolated network segment and cutting
off all access from the public internet we increase the security of our stack.
This allows us to focus more on defending the edge of our network (the area
where traffic actually ingresses) and worry less about compromise in resources
that aren't accessible. By limiting the ingress points we effectively reduce
the attack surface.

### How is SSL Working?
In this implementation we utilized SSL Termination. This means that encrypted
web traffic is decrypted at the load balancer and forward across unencrypted to
the web servers. This allows us to put the computationally heavy task on the 
load balancer and not stress the webservers. This can be changed to use
an SSL Pass Through where the load balancer would forward the traffic to the 
droplets, who then would have to decrypt the traffic. Using SSL Termination 
means we don't have to configure the webservers to handle SSL, hopefully
making the configuration simpler.

### How Do I SSH Into the Webservers?
The purpose of the bastion host is to act as a "jump box" where a user who
wants to access the webservers via ssh would first SSH into this server, then
ssh into the individual droplet they wanted to. This allows us to harden our
bastion and only allow `ssh` traffic. However, since we use ssh key auth we
don't want to add our private keys to the bastion for fear of compromise. We
can solve this issue by using the `ssh-agent` to forward our identity to the
bastion, who will in turn forward the identity to the webserver droplets. Since
our public key will be on both the bastion and the webserver droplets this will
allow us to ssh into both without having to store our sensitive key on the
bastion host. 

To enable the `ssh-agent` on your local host run the following commands.
```
eval `ssh-agent`
ssh-add
```

Once you are ready to connect to a webserver droplet ssh into the bastion via
its ip or fully qualified domain name and pass the `-A` flag to forward your ssh
agent along.
```
ssh -A user@BASTION_FQDN
```

Once you are in the bastion you can ssh into any of the webserver droplets
via it's private IP address.
```
ssh user@private_ip_address
```

### I've Stood Up the Stack, Now What? 
The terraform code does not do any default configuration of the server, so you
may want to follow the [Initial Server Setup](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-20-04) 
guide before you go to far. You'll then want to deploy your code, [connect
to the database](https://www.digitalocean.com/community/tutorials/how-to-connect-to-managed-database-ubuntu-18-04) if necessary, and build
your dream application.  

## How to Use This
This directory is a self contained production ready environment. You can clone
this repository and run terraform from within this directory or copy the files
elsewhere.

### Variables
The first thing you need to do is create a variables file. `nyc3.tfvars` and
`sfo2.tfvars` are sample variable files that have `CHANGE_ME` in them where
certain fields need to be updated. If you name your file `terraform.tfvars` or
have the `.auto.tfvars` extension when you run terraform it will automatically 
use these files. If not you will have to specify the file via the command line.

#### Required Variables
These variables must be declared in your `.tfvars` variable file or set as
environment variables.

* `do_token` - Your DigitalOcean API Token. Set this as an environment variable
               by running `export TF_VARS_do_token=MY_DO_TOKEN`.
* `ssh_key` - Name of your SSH Hey as it appears in the DigitalOcean dashboard
* `subdomain` - The first part of your URL. Ex: The `www` in `www.digitalocean.com`
* `domain_name` - Domain you have registerd and managed by DigitalOcean

#### Optional Variables
These variables are up to you if you want to change them, or just go with 
the defaults set. It is _very_ likely that, in a production setting, you'll want
to change some of these.

# Name of your project. Will be prepended to most resources
* `name` - The name of your project. Will be prepended to most resources.
  * default: `minimal-vpc`
* `region` - The region to deploy your infrastructure to.
  * default: `nyc3`
* `droplet_count` - The number of webserver droplets to create.
  * default: `1`
* `db_count` - The number of database nodes to create.
  * default: `1`
* `droplet_size` - The size we want our droplets to be. Can view slugs (valid options) [here](https://slugs.do-api.dev/)
  * default: `s-1vcpu-1gb`
* `database_size` - The size we want our database images to be.
  * default: `db-s-1vcpu-1gb`
* `image` - The operating system image we want to use. Can view slugs (valid options) [here](https://slugs.do-api.dev/)
  * default: `ubuntu-20-04-x64`

### Output Variables
Output variables will be displayed after you execute a `terraform apply`.

* `web_servers_private` - Private IPs of the webserver droplets
* `web_loadbalancer_fqdn` - Fully qualified domain name of the load balancer
* `bastion_fqdn` - Fully qualified domain name of the bastion
* `database_port` - Port the postgres database is listening on
* `database_private_uri` - The URI for connecting to the database
* `database_name` - The default database name
* `database_user` - The default database username
* `database_password` - The default database user password.

### How to Execute

1. Follow the instruction to [install Terraform](https://www.terraform.io/downloads.html).
2. Ensure you created a `tfvars` variable file as specified above in the 
[Required and Optional Variables](#required-and-optional-variables) section. 
3. Run `terraform init`. This will initialize this directory as a terraform 
directory and download the DigitalOcean provider.
4. Export your DigitalOcean API key as an environment variable like so:
`export TF_VARS_do_token="MYDOTOKEN"`.
5. Run `terraform plan -var-file=YOUR_VARS.tfvars -out=infra.out`. This command 
will create a plan of the infrastructure for you to review and save it to 
`infra.out`.
6. If you are satisfied with the plan produced by the above step, run 
`terraform apply "infra.out"` to create the infrastructure.
7. You can repeat steps 5 & 6 if you decide to modify the terraform files after
you have deployed. Be sure to pay attention to the plan, as some resources
may need to be destroyed for the alterations to take affect.
8. When you are ready to delete the infrastructure run 
`terraform destroy -var-file=YOUR_VARS.tfvars`

### Execution tips.

* You can name your vars file `terraform.tfvars` or give it the extension 
`.auto.tfvars` and terraform will automatically select this file. No need for
the `-var-file` flag then.
* If you plan on using this for multiple regions/deployments you should read
up on [Terraform workspaces](https://www.terraform.io/docs/state/workspaces.html).
* To view the outputs from your execution at any time run `terraform output`.

## Extra Resources

* Learn Terraform
    * [HashiCorp Training](https://learn.hashicorp.com/terraform)
    * [My Terraform Webinar](https://www.youtube.com/watch?v=U5suIJwobiQ)
    * [My Terraform Webinar Code and Examples](https://github.com/Zelgius/Infrastructure-As-Code-Intro)
* [DigitalOcean Product Docs](https://www.digitalocean.com/docs/)

## Contributors

* Mason Egger - Primary Author
