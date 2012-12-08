node 'hetzner02' {
  include postfix
  include hdo::webapp::nginx
  include hdo::webapp::apiupdater
  include hdo::database
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
  include nagios::target
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
