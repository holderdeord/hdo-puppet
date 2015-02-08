class hdo::webapp::rebeltweeter($ensure = present) {
  include hdo::params

  if ! ($ensure in [ 'present', 'absent' ]) {
    fail('apichangelog ensure parameter must be absent or present')
  }

  cron { 'hdo-rebel-tweeter':
    ensure      => $ensure,
    command     => "bash -l -c 'cd ${hdo::params::app_root} && bundle exec rake twitter:rebels'",
    user        => hdo,
    environment => ["RAILS_ENV=${hdo::params::environment}", 'PATH=/usr/local/bin:/usr/bin:/bin', "MAILTO=${hdo::params::admin_email}"],
    require     => Class['hdo::webapp'],
    hour        => '9',
    minute      => '10'
  }

}
