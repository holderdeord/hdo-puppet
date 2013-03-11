#
# {ops1,munin,puppet,deploy,graphite,nagios}.holderdeord.no
#

node 'ops1' {
  include munin::master
  include nagios::monitor

  include graphite
  include statsd

  include hdo::deployer
  include hdo::puppethipchat

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
  include hdo::webapp::apiupdater

  class { 'hdo::webapp':
    server_name => 'beta.holderdeord.no'
  }

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

  class { 'hdo::webapp':
    server_name => 'next.holderdeord.no',
    listen      => 8080 # varnish listening on 80
  }

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

node 'app1', 'app2' {
  include munin::node
  include nagios::target
  include nagios::target::http

  class { 'hdo::webapp':
    db_host           => '46.4.88.199',
    elasticsearch_url => 'http://46.4.88.197:9200'
  }
}

#
# elasticsearch servers
#

node 'es1' {
  include munin::node
  include nagios::target

  include elasticsearch

  hdo::firewall { "es1": }
}

#
# db servers
#

node 'db1' {
  include munin::node
  include nagios::target

  include hdo::database
}
