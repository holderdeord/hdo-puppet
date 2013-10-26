#
# this should only run once per database
#

class hdo::webapp::apiupdater(
  $ensure = present,
  $hour   = 1,
  $minute = 30
) {
  include hdo::params

  if ! ($ensure in [ 'present', 'absent' ]) {
    fail('apiupdater ensure parameter must be absent or present')
  }

  $logdir  = '/var/log/hdo-api-updater'
  $logfile = "${logdir}/updater.log"

  file { $logdir:
    ensure => directory,
    owner  => hdo
  }

  file { $logfile:
    ensure => file,
    owner  => hdo
  }

  logrotate::rule { 'hdo-api-updater':
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
    command     => "bash -l -c 'cd ${hdo::params::app_root} && bundle exec script/import daily >> ${logfile}'",
    user        => hdo,
    environment => ["RAILS_ENV=${hdo::params::environment}", 'PATH=/usr/local/bin:/usr/bin:/bin', "MAILTO=${hdo::params::admin_email}"],
    require     => [Class['hdo::webapp'], File[$logfile]],
    hour        => $hour,
    minute      => $minute
  }
}