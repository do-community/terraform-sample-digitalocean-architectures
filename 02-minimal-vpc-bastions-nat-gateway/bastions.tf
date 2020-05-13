################################################################################
# Create n web servers with nginx installed and a custom message on main page  #
################################################################################
resource "digitalocean_droplet" "bastion" {

    # Number of bastion droplets to create. Taken from our variables
    count = var.bastion_count

    # Which image to use. Taken from our variables
    image = var.image

    # human friendly name for the droplet
    name = "bastion-${var.name}-${var.region}-${count.index + 1}"

    # What region to deploy the droplet(s) to. Taken from our variables
    region = var.region
    
    # Size of the bastion. Can be small since it's only doing ssh
    size = "s-1vcpu-1gb"

    # The ssh keys to put on the server so we can access it. Read in through a 
    # data source
    ssh_keys = [data.digitalocean_ssh_key.main.id]

    # What VPC to put our droplets in
    vpc_uuid = digitalocean_vpc.web.id
}

################################################################################
# DNS record for each of our bastion servers. The name will be                 #
# bastion-<NAME>-<REGION>-<INDEX+1> where name comes from our variables.       #
# We create these so if our Load Balancer goes down we can still access the    #
# individual bastions hosts (assuming we have more than 1)                     #
################################################################################
resource "digitalocean_record" "bastion-hosts" {

    # The number of DNS records to create
    count = var.bastion_count

    # Get the domain from our data source
    domain = data.digitalocean_domain.web.name

    # An A record is an IPv4 name record. Like www.digitalocean.com
    type   = "A"

    # Set the name to bastion-name-region-index
    name   = "bastion-${var.name}-${var.region}-${count.index + 1}"

    # IP address of the bastion to assign the record to
    value  = digitalocean_droplet.bastion[count.index].ipv4_address

    # The Time-to-Live for this record is 30 seconds. Then the cache invalidates
    ttl    = 300
}

################################################################################
# DNS record for the name of our bastion load balancer. The name will be       #
# bastion-<NAME>-<REGION> where name comes from our variables                  #
################################################################################
resource "digitalocean_record" "bastion-lb" {

    # Get the domain from our data source
    domain = data.digitalocean_domain.web.name

    # An A record is an IPv4 name record. Like www.digitalocean.com
    type   = "A"

    # Set the name to bastion-name-region-index
    name   = "bastion-${var.name}-${var.region}"

    # IP address of the bastion to assign the record to
    value  = digitalocean_loadbalancer.bastion.ip

    # The Time-to-Live for this record is 30 seconds. Then the cache invalidates
    ttl    = 300
}

################################################################################
# Load Balancer for distributing traffic amongst our web servers. Uses SSL     #
# termination and forwards HTTPS traffic to HTTP internally                    #
################################################################################
resource "digitalocean_loadbalancer" "bastion" {

    # The user friendly name of the load balancer
    name        = "bastion-${var.name}-${var.region}"

    # What region to deploy the LB to.
    region      = var.region

    # # Which droplets should the load balancer route traffic to
    droplet_ids = digitalocean_droplet.bastion.*.id

    # What VPC to put the load balancer in
    vpc_uuid = digitalocean_vpc.web.id

    #--------------------------------------------------------------------------#
    # Forward all traffic received on port 22 using the tcp protocol to        #
    # Port 22 using the tcp protocol of the hosts behind this load balancer    #
    #--------------------------------------------------------------------------#
    forwarding_rule {
        entry_port = 22
        entry_protocol = "tcp"

        target_port = 22
        target_protocol = "tcp"
    }

    # Set our healthcheck to port 22 since we aren't load balancing http
    healthcheck { 
        port = 22
        protocol = "tcp"
    }

    #-----------------------------------------------------------------------------------------------#
    # Ensures that we create the new resource before we destroy the old one                         #
    # https://www.terraform.io/docs/configuration/resources.html#lifecycle-lifecycle-customizations #
    #-----------------------------------------------------------------------------------------------#
    lifecycle {
        create_before_destroy = true
    }
}

################################################################################
# Create firewall rules for allowing only ssh traffic to and from the bastion  #
################################################################################
resource "digitalocean_firewall" "bastion" {
    
    # Human friendly name of the firewall
    name = "${var.name}-only-ssh-bastion"

    # Droplets to apply the firewall to
    droplet_ids = digitalocean_droplet.bastion.*.id

    #--------------------------------------------------------------------------#
    # Rules to allow only ssh both inbound from the public internet and only   #
    # allow outbout ssh traffic into the VPC network. Also allow ping just for #
    # ease of use inside the VPC as well.                                      #
    #--------------------------------------------------------------------------#
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