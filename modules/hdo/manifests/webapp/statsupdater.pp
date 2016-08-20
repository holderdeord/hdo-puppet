class hdo::webapp::statsupdater(
  $ensure = present,
  $hour   = 5,
  $minute = 50
) {
  include hdo::params

  if ! ($ensure in [ 'present', 'absent' ]) {
    fail('statsupdater ensure parameter must be absent or present')
  }

  $logdir  = '/var/log/hdo-stats-updater'
  $logfile = "${logdir}/updater.log"

  file { $logdir:
    ensure => directory,
    owner  => hdo
  }

  file { $logfile:
    ensure => file,
    owner  => hdo
  }

  logrotate::rule { 'hdo-stats-updater':
    ensure       => $ensure,
    path         => $logfile,
    compress     => true,
    copytruncate => true,
    dateext      => true,
    ifempty      => false,
    missingok    => true
  }

  cron { 'api-update':
    ensure      => $ensure,
    command     => "bash -l -c 'cd ${hdo::params::app_root} && bundle exec script/import stats >> ${logfile}'",
    user        => hdo,
    environment => ["RAILS_ENV=${hdo::params::environment}", 'PATH=/usr/local/bin:/usr/bin:/bin', "MAILTO=${hdo::params::admin_email}"],
    require     => [Class['hdo::webapp'], File[$logfile]],
    hour        => $hour,
    minute      => $minute
  }
}