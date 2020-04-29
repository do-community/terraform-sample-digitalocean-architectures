variable "do_token" {}
provider "digitalocean" {
    token = var.do_token
}

data "digitalocean_ssh_key" "home" {
    name = "Home Desktop WSL"
}

resource "digitalocean_vpc" "main" {
    name = "mason-vpc"
    region = "nyc3"
    ip_range = "192.168.93.0/24"
}

resource "digitalocean_droplet" "web" {
    count = 3
    image = "ubuntu-18.04-x64"
    name = "web-${count.index + 1}"
    region = "nyc3"
    size = "s-1vcpu-1gb"
    vpc_uuid = digitalocean_vpc.main.id
}

resource "digitalocean_droplet" "bastion" {
    image = "ubuntu-18.04-x64"
    name = "bastion"
    region = "nyc3"
    size = "s-1vcpu-1gb"
    vpc_uuid = digitalocean_vpc.main.id
}