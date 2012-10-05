#
# this should only run on a single node!
#

class hdo::backend::apiupdater($ensure = present) {
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
    environment => ['RAILS_ENV=production', 'PATH=/usr/local/bin:/usr/bin:/bin', 'MAILTO=jari@holderdeord.no'],
    require     => [Class['hdo::backend'], File[$logfile]],
    hour        => 6,
    minute      => 30
  }
}