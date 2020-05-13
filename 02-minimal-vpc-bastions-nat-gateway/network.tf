################################################################################
# Create a VPC for isolating our traffic                                       #
################################################################################
resource "digitalocean_vpc" "web"{
    # The human friendly name of our VPC.
    name = var.name

    # The region to deploy our VPC to.
    region = var.region

    # The private ip range within our VPC
    ip_range = var.vpc_ip_range
}