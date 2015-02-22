#
# {ops1,munin,puppet,deploy,graphite,nagios}.holderdeord.no
#

node 'ops1' {
  include hdo::users::admins
  include postfix

  include munin::master
  include munin::node
  class { 'hdo::collectd::default': version => '5.4.0-3ubuntu2' }

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

  class { 'nodejs': manage_repo => true }
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

  class { 'nodejs': manage_repo => true }

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
  class { 'hdo::webapp::apiupdater':
    hour => 18
  }

  class { 'hdo::blog':
    server_name => 'drafts.holderdeord.no',
    drafts      => true
  }

  class { 'hdo::transcripts':
    server_name => 'transcripts-staging.holderdeord.no'
  }

  hdo::firewall { "next": }
}

#
# app server
# holderdeord.no A record (301 -> www/fastly -> app)
# 'files' server
#

node 'app' {
  include hdo::users::admins

  include munin::node
  include hdo::collectd::default
  include nagios::target
  include nagios::target::http

  class { 'nodejs': manage_repo => true }

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

  include hdo::files
  include hdo::webapp::graphite
  include hdo::webapp::exporter
  include hdo::webapp::apichangelog
  include hdo::webapp::apiupdater
  include hdo::webapp::rebeltweeter

  hdo::firewall { "app": }
  hdo::networkinterfaces { "app": }
}
