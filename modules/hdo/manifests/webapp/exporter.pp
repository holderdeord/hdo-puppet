class hdo::webapp::exporter(
  $ensure = present,
  $hour   = 6,
  $minute = 30
) {
  include hdo::params

  $root = '/webapps/files/data/csv'

  if ! ($ensure in [ 'present', 'absent' ]) {
    fail('apiupdater ensure parameter must be absent or present')
  }

  cron { 'data-export':
    ensure      => $ensure,
    command     => "bash -l -c 'cd ${hdo::params::app_root} && bundle exec script/export /tmp/hdo-csv-dump-$(date +%F) && tar zcf /webapps/files/data/csv/latest.tgz -C /tmp/ hdo-csv-dump-$(date +%F)'",
    user        => postgres,
    environment => ["RAILS_ENV=${hdo::params::environment}", 'PATH=/usr/local/bin:/usr/bin:/bin', "MAILTO=${hdo::params::admin_email}"],
    require     => Class['hdo::webapp'],
    hour        => $hour,
    minute      => $minute
  }
}