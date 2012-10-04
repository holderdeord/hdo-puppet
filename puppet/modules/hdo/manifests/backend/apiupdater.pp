#
# this should only run on a single node!
#

class hdo::backend::apiupdater {
  include hdo::params

  $logfile = '/var/log/hdo-api-updater.log'

  file { $logfile:
    ensure => file,
    owner  => hdo
  }

  cron { 'api-update':
    command     => "cd ${hdo::params::app_root} && bundle exec script/import daily >> ${logfile} 2>&1",
    user        => hdo,
    environment => 'RAILS_ENV=production',
    require     => [Class['hdo::backend'], File[$logfile]],
    minute      => '*/30' # for testing
  }
}