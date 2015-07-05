#
# Staging / backup server
#

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
    drafts      => true,
    restrict    => true,
  }

  class { 'hdo::database::backup_sync':
    target      => 'hdo@hdo02.holderdeord.no:pg-backups',
    destination => "${hdo::params::home}/pg-backups-sync",
  }

  hdo::firewall { 'basic': }
}

