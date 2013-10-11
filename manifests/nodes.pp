#
# {ops1,munin,puppet,deploy,graphite,nagios}.holderdeord.no
#

node 'ops1' {
  include hdo::users::admins
  include postfix

  include munin::master
  include munin::node

  include nagios::monitor
  include nagios::monitor::front
  include nagios::hipchat

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
  class { 'elasticsearch::emailmonitor': ensure => absent }

  class { 'hdo::database':
    munin        => true,
    local_backup => absent,
  }

  class { 'hdo::webapp':
    server_name => 'next.holderdeord.no',
    listen      => 80,
    ssl         => true,
  }

  # run api updates some hours before prod
  class { 'hdo::webapp::apiupdater': hour => 18 }

  hdo::firewall { "next": }
}

#
# file server + holderdeord.no A record (301 -> www)
#

node 'files' {
  include hdo::users::admins

  include munin::node
  include nagios::target
  include nagios::target::http

  include hdo::files

  hdo::networkinterfaces { "files": }
}

#
# app servers
#

node 'app1' {
  include hdo::users::admins

  class { 'postfix':
    smtp_listen          => 'all',
    # if you modify network_table_extras, remember to add the ip to the app iptables rules
    network_table_extras => ["46.4.88.195", "46.4.88.196"]
  }

  include munin::node
  include nagios::target
  include nagios::target::http
  include hdo::webapp::default
  include hdo::webapp::graphite

  # API import only happens on the 'primary' app server
  class { 'hdo::webapp::apiupdater': }

  hdo::firewall { "app": }
  hdo::networkinterfaces { "app1": }
}

node 'app2' {
  include hdo::users::admins

  include munin::node
  include nagios::target
  include nagios::target::http

  include hdo::webapp::default

  hdo::firewall { "app": }
  hdo::networkinterfaces { "app2": }
}

#
# elasticsearch servers
#

node 'es1', 'es2' {
  include hdo::users::admins

  include munin::node
  include nagios::target

  include elasticsearch

  hdo::firewall { "es": }
}

#
# db servers
#

node 'db1' {
  include hdo::users::admins

  include munin::node
  include nagios::target

  class { 'hdo::database':
    standby_ip   => '88.198.14.8', # db2
    local_backup => present,
    munin        => true,
  }
}

node 'db2' {
  include hdo::users::admins

  include munin::node
  include nagios::target

  class { 'hdo::database':
    primary_ip   => '46.4.88.199', # db1
    local_backup => present,
    munin        => true,
  }
}
