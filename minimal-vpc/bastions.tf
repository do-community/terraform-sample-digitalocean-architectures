resource "digitalocean_droplet" "bastion" {
    image = "ubuntu-18-04-x64"
    name = "bastion-${var.region}"
    region = var.region
    size = "s-1vcpu-1gb"
    ssh_keys = [data.digitalocean_ssh_key.home.id]
    vpc_uuid = digitalocean_vpc.web.id
}

resource "digitalocean_record" "bastion-hosts" {
    domain = data.digitalocean_domain.web.name
    type   = "A"
    name   = "bastion-${var.region}"
    value  = digitalocean_droplet.bastion.ipv4_address
    ttl    = 30
}

resource "digitalocean_firewall" "bastion" {
    name = "only-ssh-bastion"

    droplet_ids = [digitalocean_droplet.bastion.id]

    inbound_rule {
        protocol = "tcp"
        port_range = "22"
        source_addresses = ["0.0.0.0/0", "::/0"]
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