################################################################################
# This terraform project aims to provide a minimal viable deployment of a      #
# load balanced web platform, using a database within a Virtual Private Cloud. #
#                                                                              #
#              *For This Example, We're Going to Have 3 Web Servers*           #
# This deployment will take http traffic on port 80 and forward it to 3 web    #
# servers. We will also have a bastion host, also known as a jump box, that we #
# will use to ssh into the 
#                          |                                                   #
#                         http                                                 #
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



