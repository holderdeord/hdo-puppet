node 'default' {
  include hdo::webapp::nginx
  include hdo::database
  # include munin::master
  # include munin::node
  # include elasticsearch
}

node 'beta.holderdeord.no' {
  include hdo::webapp::apache
  include hdo::database
}


#
# testing azure
#

node 'hdo01', 'hdo02' {
  include hdo::webapp::apache
  include hdo::webapp::apiupdater
  include hdo::database
}

node 'hdo-staging.nuug.no' {
  include hdo::webapp::apache
  include hdo::database
}
