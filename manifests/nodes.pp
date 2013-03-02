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

#
# cache servers
#

node 'cache1' {
  include munin::node
}

#
# app servers
#

node 'app1', 'app2' {
  include munin::node
}

#
# elasticsearch servers
#

node 'es1' {
  include munin::node
  include elasticsearch
  include elasticsearch::emailmonitor
}

#
# db servers
#

node 'db1' {
  include munin::node
  include hdo::database
  include nagios::target
}
