#
# {ops1,munin,puppet,deploy,graphite,nagios}.holderdeord.no
#

node 'ops1' {
  include hdo::users::admins

  include munin::master
  include nagios::monitor

  include graphite
  include statsd

  include hdo::deployer
  include hdo::puppethipchat

  hdo::firewall { "ops1": }
}

#
# next.holderdeord.no
#

node 'hetzner03' {
  include hdo::users::admins
  include postfix

  include munin::node
  include nagios::target
  include nagios::target::http

  include elasticsearch
  include elasticsearch::emailmonitor

  include hdo::database

  class { 'hdo::webapp':
    server_name => 'next.holderdeord.no',
    listen      => 80,
    ssl         => true,
  }

  class { 'hdo::webapp::apiupdater':
    ensure => absent
  }

  class { 'varnish':
    ensure      => absent,
    listen_port => 80,
  }

  hdo::firewall { "next": }
}

#
# cache servers
#

node 'cache1' {
  include hdo::users::admins

  include munin::node
  include nagios::target
  include nagios::target::http

  class { 'varnish':
    listen_port => 80,
    backends    => [
      { host => 'app1.holderdeord.no', port => 80 },
      { host => 'app2.holderdeord.no', port => 80 },
    ]
  }
}

#
# app servers
#

node 'app1' {
  include hdo::users::admins

  include munin::node
  include nagios::target
  include nagios::target::http
  include hdo::webapp::default

  # API import only happens on the 'primary' app server
  include postfix
  include hdo::webapp::apiupdater

  hdo::firewall { "app": }
}

node 'app2' {
  include hdo::users::admins

  include munin::node
  include nagios::target
  include nagios::target::http

  include hdo::webapp::default

  hdo::firewall { "app": }
}

#
# elasticsearch servers
#

node 'es1' {
  include hdo::users::admins

  include munin::node
  include nagios::target

  include elasticsearch

  hdo::firewall { "es1": }
}

#
# db servers
#

node 'db1' {
  include hdo::users::admins

  include munin::node
  include nagios::target

  include hdo::database
}
