################################################################################
# Create a database cluster using Postgres 11 with variable node count within  #
# the VPC                                                                      #
################################################################################
resource "digitalocean_database_cluster" "postgres-cluster" {
    
    # Name of the database
    name       = "${var.name}-database-cluster"

    # The database engine to use. Currently Postgres. Could be MySql or Redis
    engine     = "pg"

    # Version of the engine. So Postgres 11
    version    = "11"

    # Size of the database instance
    size       = var.database_size

    # Region to deploy the database to
    region     = var.region

    # How many database nodes do we want
    node_count = var.db_count

    # VPC to put the 
    private_network_uuid = digitalocean_vpc.web.id
}

################################################################################
# Specify that only resources with a specific tag can access this database.    #
# Currently the web server droplets are tagged with this so they can access.   #
################################################################################
resource "digitalocean_database_firewall" "postgress-cluster-firewall" {
    
    # Database cluster ID to associate this firewall rule with
    cluster_id = digitalocean_database_cluster.postgres-cluster.id

    #--------------------------------------------------------------------------#
    # Rule to allow resources tagged with the interpolated tag                 # 
    # (e.g. minimal-vpc-webserver) to be able to access the database           #
    #--------------------------------------------------------------------------#
    rule {
        type = "tag"
        value = "${var.name}-webserver"
    }
}