class hdo::promiseprogress(
  $spreadhsheetId = '14LtkMlUJ3K7BPz_bJOEVjtktBK9V3tVeDLu5D1qiRnQ'
  $root           = '/var/lib/hdo-promise-progress'
  $out            = '/webapps/files/analyse/2017/loftesjekk'
) {
  include hdo::common
  $script = "${root}/hdo-promise-progress.rb"

  file { $root:
    ensure => directory
  }

  file { $script:
    ensure  => file,
    owner   => $hdo::params::user,
    mode    => '0744',
    source => 'puppet:///modules/hdo/promiseprogress/hdo-promise-progress.rb'
    require => File[$root]
  }

  cron { 'hdo-promise-progress':
    ensure      => 'present',
    command     => "bash -l -c 'ruby ${script} --input /webapps/files/gdrive/${spreadhsheetId}.json --output ${out}'",
    owner       => $hdo::params::user,
    environment => ['PATH=/usr/local/bin:/usr/bin:/bin', "MAILTO=${hdo::params::admin_email}"],
    require     => File[$script],
    hour        => '*',
    minute      => '*/1'
  }
}
