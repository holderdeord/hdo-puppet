class hdo::transcripts(
  $ensure      = 'present',
  $server_name = 'transcripts.holderdeord.no',
  $port        = 7575,
  $restrict    = false,
  $ssl         = false
  ) {
  include hdo::common
  include hdo::params

  $app_name         = 'hdo-transcript-search'
  $transcripts_root = "${hdo::params::webapp_root}/${app_name}"
  $indexer_root     = "${transcripts_root}/indexer"
  $indexer_log      = '/var/log/hdo-transcript-indexer.log'
  $app_root         = "${transcripts_root}/webapp"
  $public_root      = "${app_root}/public"

  exec { "clone ${app_name}":
    command => "git clone git://github.com/holderdeord/${app_name} ${transcripts_root} && cd ${transcripts_root} && npm install",
    user    => hdo,
    creates => $app_root,
    require => [Package['git-core'], File[$hdo::params::webapp_root]]
  }

  exec { "build ${app_name} webapp":
    command     => "bash -l -c 'npm run build'",
    user        => hdo,
    cwd         => $app_root,
    onlyif      => "ls ${public_root}/ | grep -Ev 'bundle.+.js$' > /dev/null",
    environment => ["HOME=${hdo::params::home}"],
    require     => [Class['hdo::nodejs'], Exec["clone ${app_name}"]]
  }

  exec { "bundle ${app_name} indexer":
    command => "bash -l -c 'bundle install --deployment'",
    cwd     => $indexer_root,
    user    => hdo,
    require => [Exec["clone ${app_name}"], Ruby::Gem['bundler']]
  }

  $purge = true
  $passenger_startup_file = 'server.js'

  file { "${passenger::nginx::sites_dir}/transcripts.holderdeord.no.conf":
    ensure  => $ensure,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('hdo/nginx-node-app-vhost.conf.erb'),
    notify  => Service['nginx']
  }

  file { $indexer_log:
    ensure => $ensure,
    owner  => hdo,
  }

  cron { "index ${app_name} daily":
    ensure      => $ensure,
    command     => "bash -l -c 'cd ${indexer_root} && bundle exec ruby -Ilib bin/hdo-transcript-indexer --mail > ${indexer_log}'",
    user        => hdo,
    environment => ['PATH=/usr/local/bin:/usr/bin:/bin', "MAILTO=${hdo::params::admin_email}"],
    require     => [Exec["bundle ${app_name} indexer"], File[$indexer_log]],
    hour        => '4',
    minute      => '50'
  }

  cron { "download images for ${app_name} weekly":
    ensure      => $ensure,
    command     => "bash -l -c 'cd ${indexer_root} && bundle exec ruby ../scripts/download_images.rb > /dev/null'",
    user        => hdo,
    environment => ['PATH=/usr/local/bin:/usr/bin:/bin', "MAILTO=${hdo::params::admin_email}"],
    require     => [Exec["bundle ${app_name} indexer"]],
    hour        => '2',
    minute      => '20',
    weekday     => '2'
  }

  logrotate::rule { "${app_name}-indexer":
    ensure       => $ensure,
    path         => $indexer_log,
    compress     => true,
    copytruncate => true,
    dateext      => true,
    ifempty      => false,
    missingok    => true
  }

  file { '/etc/profile.d/hdo-transcripts.sh':
    ensure  => $ensure,
    mode    => '0775',
    content => template('hdo/hdo-transcripts-profile.sh')
  }

  file { "/etc/init/${app_name}.conf":
    ensure  => 'absent',
  }

  logrotate::rule { $app_name:
    ensure => 'absent'
  }

  file { '/etc/sudoers.d/allow-hdo-service-hdo-transcript-search':
    ensure  => 'absent'
  }

  file { $app_log:
    ensure => 'absent',
  }

}
