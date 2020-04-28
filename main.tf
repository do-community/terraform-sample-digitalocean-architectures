variable do_token {}
provider digitalocean {
    token = var.do_token
}


resource "digitalocean_vpc" "web"{
    name = "mason-egger"
    region = var.region
    ip_range = "192.168.92.0/24"
}

resource "digitalocean_droplet" "web" {
    count = var.droplet_count
    image = "ubuntu-18-04-x64"
    name = "web-${var.region}-${count.index +1}"
    region = var.region
    size = var.droplet_size
    ssh_keys = [data.digitalocean_ssh_key.home.id]
    vpc_uuid = digitalocean_vpc.web.id


    user_data = <<EOF
    #cloud-config
    packages:
        - nginx
    runcmd:
        - [ sh, -xc, "echo '<h1>web-${var.region}-${count.index +1}</h1>' >> /var/www/html/index.nginx-debian.html"]
    EOF

    # ensures that we create the new resource before we destroy the old one
    # https://www.terraform.io/docs/configuration/resources.html#lifecycle-lifecycle-customizations
    lifecycle {
        create_before_destroy = true
    }
}

resource "digitalocean_loadbalancer" "web" {
    name        = "web-${var.region}"
    region      = var.region
    droplet_ids = digitalocean_droplet.web.*.id
    vpc_uuid = digitalocean_vpc.web.id

    forwarding_rule {
        entry_port = 80
        entry_protocol = "http"

        target_port = 80
        target_protocol = "http"
    }


    lifecycle {
        create_before_destroy = true
    }
}

resource "digitalocean_firewall" "web" {
    name = "only-vpc-traffic"

    droplet_ids = digitalocean_droplet.web.*.id

    inbound_rule {
        protocol = "tcp"
        port_range = "1-65535"
        source_addresses = [digitalocean_vpc.web.ip_range]
    }

    inbound_rule {
        protocol = "udp"
        port_range = "1-65535"
        source_addresses = [digitalocean_vpc.web.ip_range]
    }

    inbound_rule {
        protocol = "icmp"
        source_addresses = [digitalocean_vpc.web.ip_range]
    }

    outbound_rule {
        protocol = "udp"
        port_range = "1-65535"
        destination_addresses = [digitalocean_vpc.web.ip_range]
    }

    outbound_rule {
        protocol = "tcp"
        port_range = "1-65535"
        destination_addresses = [digitalocean_vpc.web.ip_range]
    }

    outbound_rule {
        protocol = "icmp"
        destination_addresses = [digitalocean_vpc.web.ip_range]
    }
}

resource "digitalocean_record" "web" {
    domain = data.digitalocean_domain.web.name
    type   = "A"
    name   = var.region
    value  = digitalocean_loadbalancer.web.ip
    ttl    = 30
}
