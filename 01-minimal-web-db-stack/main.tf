################################################################################
# This terraform project aims to provide a minimal viable deployment of a      #
# load balanced web platform, using a database within a Virtual Private Cloud. #
#                                                                              #
#            *For This Example, We're Going to Have 3 Web Servers*             #
# This deployment will take https traffic on port 443 and forward it to port 80#
# on the internal web servers (This is known as SSL termination) via a round   # 
# robin algorithm. We will have a bastion host, also known as a jump box, that #
# we will use to ssh into the private droplets. The droplets will access a     #
# managed database that will also be secured within the  VPC.                  #
#                                                                              # 
# Following recommended practice for terraform file configuration, the         #
# different components of this architecture have been separated into different #
# files. You can find the implementation of the following components in the    #
# following files:                                                             #
#                                                                              #
# * main.tf        - This file. Declare providers and document infrastructure  #
# * data.tf        - All data sources that could be need across different tf   #
#                    files                                                     #
# * variables.tf   - All variables defined for use within the different tf     #
#                    files                                                     #
# * web-servers.tf - Contains the droplets, DNS records, and firewall rules    #
#                    for the web server droplets                               #
# * network.tf     - Contains top level networking config such as VPC          #
# * database.tf    - Contains the Database cluster, users and databases        #
# * bastions.tf    - Contains the droplets, DNS records, and firewall rules    #
#                    for the bastion droplets                                  #
#                                                                              #    
#------------------------------------------------------------------------------#
# Architecture Diagram                                                         #
#------------------------------------------------------------------------------#
#                                                                              #    
#                          |                                                   #
#                         https                                                #
#                          |                                                   #
#                          v                                                   # 
#                +--------------------+                                        #
#                |    Load Balancer   |                                        #
#   +----------------------------------------------------+                     #     
#   |            |                    |                  |                     #
#   |            +--------------------+                  |                     #
#   |                     |                              |                     #
#   |                     |                              |                     #
#   |                    http                +---------+ |                     #
#   |                     |                  |         | |                     #
#   |                     |                  |         | |                     #
#   |                     +-------SSH--------| Bastion |<--------SSH-------    #
#   |                     |                  |         | |                     #
#   |                     |                  |         | |                     #
#   |                     |                  +---------+ |                     #
#   |          +----------+---------+                    |                     #
#   |          |          |         |                    |                     #
#   |          v          v         v                    |                     #
#   |      +-------+  +-------+  +-------+               |                     #
#   |      |  web  |  |  web  |  |  web  |               |                     #
#   |      +---+---+  +---+---+  +---+---+               |                     #
#   |          |          |          |                   |                     #
#   |          |          v          |                   |                     #
#   |          |     +----------+    |                   |                     #
#   |          |     |          |    |                   |                     #
#   |          +---->| database |<---+                   |                     #
#   |                |          |                        |                     #
#   |                +----------+                        |                     #
#   +----------------------------------------------------+                     #
#                                                                              #
################################################################################

#------------------------------------------------------------------------------#

################################################################################
# Declare where we want to create our resources and provide the appropriate    #
# token                                                                        #
################################################################################
provider digitalocean {
    # Our DigitalOcean token. Taken from our variables
    token = var.do_token
}



