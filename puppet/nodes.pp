#
# Here's where you assign hostnames to their roles
#

node default {
    include hdo::backend
    include hdo::database
}

# node my-host-name {
#     include hdo::backend
# }
#
# node my-other-host-name {
#     include hdo::database
# }
