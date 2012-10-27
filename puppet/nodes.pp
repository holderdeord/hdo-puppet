node 'default' {
  # include hdo::webapp::nginx
  # include hdo::database
  # include munin::master
  # include munin::node
  include elasticsearch
}

node 'hetzner02' {
  include postfix
  include hdo::webapp::nginx
  include hdo::webapp::apiupdater
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
  include postfix
  include elasticsearch

  include hdo::webapp::nginx
  include hdo::database

  # in staging, run earlier than prod
  class { 'hdo::webapp::apiupdater':
    hour   => 18,
    minute => 30
  }
}
