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
  include kibana

  include hdo::deployer
  include hdo::puppetmasterd

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
  include postfix

  include munin::node
  include nagios::target
  include nagios::target::http

  include elasticsearch

  class { 'hdo::webapp':
    server_name       => 'app.holderdeord.no',
    db_host           => 'localhost',
    elasticsearch_url => 'http://localhost:9200'
  }

  class { 'hdo::database':
    munin        => true,
    local_backup => present,
  }

  class { 'hdo::webapp::apiupdater': }

  include hdo::files
  include hdo::webapp::graphite

  hdo::firewall { "app": }
  hdo::networkinterfaces { "files": }
}

#
# app servers
#

node 'app1' {
  include hdo::users::admins
  hdo::firewall { "app": }
  hdo::networkinterfaces { "app1": }
}

node 'app2' {
  include hdo::users::admins
  hdo::firewall { "app": }
  hdo::networkinterfaces { "app2": }
}

#
# elasticsearch servers
#

node 'es1', 'es2' {
  include hdo::users::admins
  hdo::firewall { "es": }
}

#
# db servers
#

node 'db1', 'db2' {
  include hdo::users::admins
  include hdo::users::admins
}
