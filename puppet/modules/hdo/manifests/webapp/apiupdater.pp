#
# this should only run on a single node!
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

  $logfile = '/var/log/hdo-api-updater.log'

  file { $logfile:
    ensure => file,
    owner  => hdo
  }

  cron { 'api-update':
    ensure      => $ensure,
    command     => "cd ${hdo::params::app_root} && bundle exec script/import daily >> ${logfile} 2>&1",
    user        => hdo,
    environment => ["RAILS_ENV=${hdo::params::environment}", 'PATH=/usr/local/bin:/usr/bin:/bin', "MAILTO=${hdo::params::admin_email}"],
    require     => [Class['hdo::webapp'], File[$logfile]],
    hour        => 1,
    minute      => 30
  }
}