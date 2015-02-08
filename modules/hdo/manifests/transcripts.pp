class hdo::transcripts(
  $ensure      = 'present',
  $server_name = 'transcripts.holderdeord.no',
  $port        = 7575
  ) {
  include hdo::common
  include hdo::params

  $app_name         = 'hdo-transcript-search'
  $transcripts_root = "${hdo::params::webapp_root}/${app_name}"
  $indexer_root     = "${transcripts_root}/indexer"
  $webapp_root      = "${transcripts_root}/webapp"
  $public_root      = "${webapp_root}/public"
  $app_log          = "/var/log/${app_name}.log"

  file { $app_log:
    ensure => file,
    owner  => hdo
  }

  exec { "clone ${app_name}":
    command => "git clone git://github.com/holderdeord/${app_name} ${transcripts_root}",
    user    => hdo,
    creates => $transcripts_root,
    require => [Package['git-core'], File[$hdo::params::webapp_root]]
  }

  exec { "build ${app_name} webapp":
    command     => "bash -l -c 'npm run build'",
    user        => hdo,
    cwd         => $webapp_root,
    creates     => "${public_root}/bundle.js",
    environment => ["HOME=${hdo::params::home}"],
    require     => [Class['nodejs'], Exec["clone ${app_name}"]]
  }

  exec { "bundle ${app_name} indexer":
    command => "bash -l -c 'bundle install --deployment'",
    cwd     => $indexer_root,
    user    => hdo,
    require => Exec["clone ${app_name}"]
  }

  file { "${passenger::nginx::sites_dir}/transcripts.holderdeord.no.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('hdo/nginx-node-app-vhost.conf.erb'),
    notify  => Service['nginx']
  }

  cron { "index ${app_name} daily":
    ensure      => $ensure,
    command     => "bash -l -c 'cd ${indexer_root} && bundle exec ruby -Ilib bin/hdo-transcript-indexer'",
    user        => hdo,
    environment => ['PATH=/usr/local/bin:/usr/bin:/bin', "MAILTO=${hdo::params::admin_email}"],
    require     => Exec["bundle ${app_name} indexer"],
    hour        => '3',
    minute      => '30'
  }

  $description = $app_name
  $author      = 'hdo-puppet'
  $user        = 'hdo'

  file { "/etc/init/${app_name}.conf":
    ensure  => $ensure,
    user    => root,
    group   => root,
    content => template('hdo/node-upstart.conf.erb'),
    require => File[$app_log]
  }

  logrotate::rule { $app_name:
    ensure       => $ensure,
    path         => $app_log,
    compress     => true,
    copytruncate => true,
    dateext      => true,
    ifempty      => false,
    missingok    => true
  }
}
