#
# {ops1,munin,puppet,hooks,graphite,nagios}.holderdeord.no
#

node 'ops1' {
  include munin::master
  include nagios::monitor

  include graphite
  include statsd

  include hdo::webhooks

  hdo::firewall { "ops1": }
}

#
# beta.holderdeord.no
#

node 'hetzner02' {
  include postfix

  include munin::node
  include nagios::target
  include nagios::target::http

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
  include nagios::target::http

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
  include nagios::target

  class { 'varnish':
    listen_port => 80,
    backends    => [
      { host => '46.4.88.195', port => 80 }, # app1
      { host => '46.4.88.196', port => 80 }, # app2
    ]
  }
}

#
# app servers
#

node 'app1', 'app2' {
  include munin::node
  include nagios::target
}

#
# elasticsearch servers
#

node 'es1' {
  include munin::node
  include nagios::target

  include elasticsearch

  hdo::firewall { "es": }
  class { 'elasticsearch::emailmonitor': ensure => absent }
}

#
# db servers
#

node 'db1' {
  include munin::node
  include nagios::target

  include hdo::database
}
