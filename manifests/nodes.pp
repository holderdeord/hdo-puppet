#
# {ops1,munin,puppet,deploy,graphite,nagios}.holderdeord.no
#

node 'ops1' {
  include hdo::users::admins
  include postfix

  include munin::master
  include munin::node
  include hdo::collectd::default

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
# staging.holderdeord.no, backend for next.holderdeord.no
#

node 'staging' {
  include hdo::users::admins
  include postfix

  include munin::node
  include hdo::collectd::default
  include nagios::target
  include nagios::target::http

  class { 'hdo::elasticsearch':
    cluster_name => 'holderdeord-staging'
  }

  class { 'hdo::database':
    local_backup => absent,
    munin        => true,
    collectd     => true,
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
  include hdo::collectd::default
  include nagios::target
  include nagios::target::http

  class { 'hdo::elasticsearch': }

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
    collectd     => true,
    local_backup => present,
  }

  class { 'hdo::webapp::apiupdater': }

  include hdo::files
  include hdo::webapp::graphite
  include hdo::webapp::exporter

  hdo::firewall { "app": }
  hdo::networkinterfaces { "app": }
}
