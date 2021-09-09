# The Private IPv4 Addresses of the droplets
output "web_servers_private" {
    value = digitalocean_droplet.web.*.ipv4_address_private
}

# The fully qualified domain name of the load balancer
output "web_loadbalancer_fqdn" {
    value = digitalocean_record.web.fqdn
}

# The fully qualified domain name of the bastion host
output "bastion_fqdn" {
    value = digitalocean_record.bastion.fqdn
}

# The port the postgres database is listening on
output "database_port" {
    value = digitalocean_database_cluster.postgres-cluster.port
}

# The URI for connecting to the database
output "database_private_uri" {
    value = digitalocean_database_cluster.postgres-cluster.private_uri
    sensitive = true
}

# The name of the default database
output "database_name" {
    value = digitalocean_database_cluster.postgres-cluster.database
}

# The name of the default user
output "database_user" {
    value = digitalocean_database_cluster.postgres-cluster.user
}

# The default user password
output "database_password" {
    value = digitalocean_database_cluster.postgres-cluster.password
    sensitive = true
}