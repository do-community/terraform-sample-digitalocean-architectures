output "web_servers_public" {
    value = digitalocean_droplet.web.*.ipv4_address
}

output "web_servers_private" {
    value = digitalocean_droplet.web.*.ipv4_address_private
}

output "bastion_servers_public" {
    value = digitalocean_droplet.bastion.*.ipv4_address
}

output "bastion_servers_private" {
    value = digitalocean_droplet.bastion.*.ipv4_address_private
}

output "web_lb" {
    value = digitalocean_loadbalancer.web.ip
}

output "bastion_hosts" {
    value = digitalocean_droplet.bastion.*.name
}