resource "digitalocean_droplet" "bastion" {
    count = 3
    image = "ubuntu-18-04-x64"
    name = "bastion-${var.region}-${count.index + 1}"
    region = var.region
    size = "s-1vcpu-1gb"
    ssh_keys = [data.digitalocean_ssh_key.home.id]
    vpc_uuid = digitalocean_vpc.web.id
}

resource "digitalocean_record" "bastion-hosts" {
    count = 3
    domain = data.digitalocean_domain.web.name
    type   = "A"
    name   = "bastion-${var.region}-${count.index + 1}"
    value  = digitalocean_droplet.bastion[count.index].ipv4_address
    ttl    = 30
}

resource "digitalocean_record" "bastion-lb" {
    domain = data.digitalocean_domain.web.name
    type   = "A"
    name   = "bastion-${var.region}"
    value  = digitalocean_loadbalancer.bastion.ip
    ttl    = 30
}

resource "digitalocean_loadbalancer" "bastion" {
    name        = "bastion-${var.region}"
    region      = var.region
    droplet_ids = digitalocean_droplet.bastion.*.id
    vpc_uuid = digitalocean_vpc.web.id

    forwarding_rule {
        entry_port = 22
        entry_protocol = "tcp"

        target_port = 22
        target_protocol = "tcp"
    }

    healthcheck { 
        port = 22
        protocol = "tcp"
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "digitalocean_firewall" "bastion" {
    name = "only-ssh-bastion"

    droplet_ids = digitalocean_droplet.bastion.*.id

    inbound_rule {
        protocol = "tcp"
        port_range = "22"
        source_addresses = ["0.0.0.0/0", "::/0"]
        source_load_balancer_uids = [digitalocean_loadbalancer.bastion.id]
    }

    outbound_rule {
        protocol = "tcp"
        port_range = "22"
        destination_addresses = [digitalocean_vpc.web.ip_range]
    }

    outbound_rule {
        protocol = "icmp"
        destination_addresses = [digitalocean_vpc.web.ip_range]
    }
}