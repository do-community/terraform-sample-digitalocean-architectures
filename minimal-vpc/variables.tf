# Our DigitalOcean API token.
variable do_token {}

# The region to deploy our infrastructure to.
variable "region" {
    type    = string
    default = "nyc3"
}

# The number of droplets to create.
variable "droplet_count" {
    type = number
    default = 1
}

# The size we want our droplets to be. 
# Can view slugs (valid options) https://slugs.do-api.dev/
variable "droplet_size" {
    type = string
    default = "s-1vcpu-1gb"
}

# The operating system image we want to use. 
# Can view slugs (valid options) https://slugs.do-api.dev/
variable "image" {
    type = string
    default = "ubuntu-20-04-x64"
}