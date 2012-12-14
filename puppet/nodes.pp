node 'hetzner02' {
  include postfix
  include hdo::database
  include hdo::webapp::beta
  include hdo::webapp::apiupdater
  include munin::node
  include nagios::target

  include elasticsearch
  include elasticsearch::emailmonitor
}

node 'hetzner03' {
}

node 'ops1' {
  include munin::master
  include nagios::monitor
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

  include hdo::webapp::staging
  include hdo::database

  # in staging, run earlier than prod
  class { 'hdo::webapp::apiupdater':
    hour   => 18,
    minute => 30
  }
}
