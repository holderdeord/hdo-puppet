#
# {ops1,munin,puppet,hooks,graphite,nagios}.holderdeord.no
#

node 'ops1' {
  include munin::master
  include nagios::monitor

  include graphite
  include statsd

  include hdo::webhooks
}

#
# beta.holderdeord.no
#

node 'hetzner02' {
  include postfix

  include munin::node
  include nagios::target

  include hdo::database
  include hdo::webapp::beta
  include hdo::webapp::apiupdater

  include elasticsearch
  include elasticsearch::emailmonitor
}

#
# next.holderdeord.no
#

node 'hetzner03' {
  include postfix

  include munin::node
  include nagios::target

  include elasticsearch
  include elasticsearch::emailmonitor

  include hdo::database
  include hdo::webapp::staging

  class { 'hdo::webapp::apiupdater':
    ensure => absent
  }

  class { 'varnish':
    listen_port => 80
  }
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
