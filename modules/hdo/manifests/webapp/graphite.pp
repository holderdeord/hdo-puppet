#
# cron job to push some data to graphite
# runs every 10 minutes
#


class hdo::webapp::graphite(
  $ensure = present,
) {
  include hdo::params

  if ! ($ensure in [ 'present', 'absent' ]) {
    fail('apiupdater ensure parameter must be absent or present')
  }

  $logfile  = '/var/log/hdo-webapp-graphite.log'

  file { $logfile:
    ensure => file,
    owner  => hdo
  }

  logrotate::rule { 'hdo-webapp-graphite':
    ensure       => $ensure,
    path         => $logfile,
    compress     => true,
    copytruncate => true,
    dateext      => true,
    ifempty      => false,
    missingok    => true
  }

  cron { 'hdo-graphite':
    ensure      => $ensure,
    command     => "bash -l -c 'cd ${hdo::params::app_root} && bundle exec rake graphite:submit >> ${logfile}'",
    user        => hdo,
    environment => ["RAILS_ENV=${hdo::params::environment}", 'PATH=/usr/local/bin:/usr/bin:/bin', "MAILTO=${hdo::params::admin_email}"],
    require     => [Class['hdo::webapp'], File[$logfile]],
    minute      => '*/10'
  }
}