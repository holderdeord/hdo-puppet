#
# This is the main production server.
# The holderdeord.no A record also points to this.
#

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
    server_name       => 'data.holderdeord.no',
    db_host           => 'localhost',
    elasticsearch_url => 'http://localhost:9200',
    ssl               => true,
  }

  class { 'hdo::transcripts':
    server_name => 'tale.holderdeord.no',
    ssl         => true,
    port        => 7575
  }

  class { 'hdo::portal':
    server_name => 'www.holderdeord.no',
    ssl         => true,
    port        => 7373
  }

  class { 'hdo::database':
    munin        => false,
    collectd     => false,
    local_backup => present,
  }

  # static sites:

  class { 'hdo::agreement':
    server_name => 'enighet.holderdeord.no',
    ssl         => true
  }

  class { 'hdo::promisesearch':
    server_name  => 'lofter.holderdeord.no',
    server_alias => 'løfter.holderdeord.no xn--lfter-vua.holderdeord.no',
    ssl          => true
  }

  class { 'hdo::rebels':
    server_name => 'utbrytere.holderdeord.no',
    ssl         => true
  }

  class { 'hdo::cards':
    server_name => 'kort.holderdeord.no',
    ssl         => true,
    restrict    => true
  }

  class { 'hdo::files':
    server_name => 'files.holderdeord.no'
  }

  class { 'hdo::blog':
    server_name => 'blog.holderdeord.no',
    drafts      => true,
    restrict    => false,
  }

  class { 'hdo::searchproxy':
    server_name => 'search.holderdeord.no',
    ssl         => true
  }

  class { 'hdo::promisetracker':
    server_name => 'sjekk.holderdeord.no',
    ssl         => true,
    restrict    => false
  }

  class { 'hdo::promiseprogress':
    ensure => absent
  }

  include hdo::googledrivesync

  include hdo::webapp::apiupdater
  include hdo::webapp::exporter
  include hdo::webapp::apichangelog
  include hdo::webapp::statsupdater
  include hdo::webapp::rebeltweeter

  hdo::firewall { 'basic': }
}
