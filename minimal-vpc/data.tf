data "digitalocean_ssh_key" "home" {
    name = "Home Desktop WSL"
}

data "digitalocean_domain" "web" {
    name = "egger.codes"
}
