node 'hdo01' {
  include hdo::users::admins
  include hdo::nodejs

  class { 'postfix':
    smtp_listen => 'all',
    munin       => false
  }

  class { 'hdo::elasticsearch': }

  class { 'passenger::nginx':
    port     => 80,
    nagios   => false,
    munin    => false,
    collectd => false,
    purge    => true,
    pingdom  => true
  }

  class { 'hdo::blog':
    server_name => 'drafts.holderdeord.no',
    drafts      => true
  }

  class { 'hdo::database::backup_sync':
    target      => 'hdo@hdo02.holderdeord.no:pg-backups',
    destination => "${hdo::params::home}/pg-backups-sync",
  }

  hdo::firewall { 'basic': }
}

node 'hdo02' {
  include hdo::users::admins
  include hdo::nodejs

  class { 'postfix':
    smtp_listen => 'all',
    munin       => false
  }

  class { 'hdo::elasticsearch': }

  class { 'passenger::nginx':
    port     => 80,
    nagios   => false,
    munin    => false,
    collectd => false,
    purge    => true,
    pingdom  => true
  }

  class { 'hdo::webapp':
    server_name       => 'www.holderdeord.no',
    db_host           => 'localhost',
    elasticsearch_url => 'http://localhost:9200',
    ssl               => true
  }

  class { 'hdo::transcripts':
    server_name => 'tale.holderdeord.no',
    ssl         => true
  }

  class { 'hdo::database':
    munin        => false,
    collectd     => false,
    local_backup => present,
  }

  class { 'hdo::files':
    server_name => 'files.holderdeord.no'
  }

  include hdo::webapp::exporter
  include hdo::webapp::apichangelog
  include hdo::webapp::apiupdater
  include hdo::webapp::rebeltweeter

  hdo::firewall { 'basic': }
}
