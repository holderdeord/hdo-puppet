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
  include grafana

  include statsd
  include kibana

  include hdo::downtime
  include hdo::deployer
  include hdo::puppetmasterd

  hdo::firewall { "ops1": }

  class { 'hdo::database::backup_sync':
    target      => 'hdo@files.holderdeord.no:pg-backups',
    destination => "${hdo::params::home}/pg-backups-sync",
  }
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
# main server + holderdeord.no A record (301 -> www/fastly -> app)
#

node 'app' {
  include hdo::users::admins

  include munin::node
  include nagios::target
  include nagios::target::http

  include elasticsearch

  class { 'postfix':
    smtp_listen => 'all',
    # make sure to open firewall if you modify this:
    network_table_extras => ['46.4.88.198'],
  }

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
  hdo::networkinterfaces { "app": }
}
