class hdo::database::backup_sync(
  $ensure = 'present',
  $target = undef,
  $destination = undef,
  $minute = 50,
) {
  include hdo::params

  $backup_sync_script = '/usr/bin/hdo-backup-sync'
  $log_file = '/var/log/hdo-backup-sync/sync.log'

  if $target == undef or $destination == undef {
    fail('must specify target/destination')
  }

  $logdir  = '/var/log/hdo-backup-sync'
  $logfile = "${logdir}/sync.log"

  file { $logdir:
    ensure => directory,
    owner  => $hdo::params::user
  }

  file { $logfile:
    ensure => file,
    owner  => $hdo::params::user
  }

  logrotate::rule { 'hdo-backup-sync':
    ensure       => $ensure,
    path         => $logfile,
    compress     => true,
    copytruncate => true,
    dateext      => true,
    ifempty      => false,
    missingok    => true
  }


  file { $backup_sync_script:
    ensure  => file,
    owner   => $hdo::params::user,
    mode    => '0744',
    content => template('hdo/backup_sync.sh.erb'),
  }

  cron { 'db-backup-sync':
    ensure      => $ensure,
    command     => $backup_sync_script,
    user        => $hdo::params::user,
    environment => ['PATH=/usr/local/bin:/usr/bin:/bin', "MAILTO=${hdo::params::admin_email}"],
    minute      => $minute,
    require     => File[$backup_sync_script],
  }
}
