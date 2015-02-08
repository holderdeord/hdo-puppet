class hdo::transcripts(
  $server_name = 'transcripts.holderdeord.no',
  $port        = 7575
  ) {
  include hdo::common
  include hdo::params

  $transcripts_root = '/webapps/hdo-transcript-search'
  $indexer_root     = "${transcripts_root}/indexer"
  $webapp_root      = "${transcripts_root}/webapp"
  $public_root      = "${webapp_root}/public"

  exec { 'clone hdo-transcript-search':
    command => "git clone git://github.com/holderdeord/hdo-transcript-search ${transcripts_root}",
    user    => hdo,
    creates => $transcripts_root,
    require => [Package['git-core'], File[$hdo::params::webapp_root]]
  }

  exec { 'build hdo-transcript-search webapp':
    command => "bash -l -c 'npm build'",
    user    => hdo,
    cwd     => $webapp_root,
    creates => "${public_root}/bundle.js",
    require => Class['nodejs']
  }

  exec { 'bundle hdo-transcript-search indexer':
    command => "bash -l -c 'bundle install --deployment'",
    cwd     => $indexer_root,
    user    => hdo,
    require => Exec['clone hdo-transcript-search']
  }

  file { "${passenger::nginx::sites_dir}/transcripts.holderdeord.no.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('hdo/nginx-node-app-vhost.conf.erb'),
    notify  => Service['nginx']
  }

  cron { 'index hdo-transcript-search daily':
    ensure      => present,
    command     => "bash -l -c 'cd ${indexer_root} && bundle exec ruby -Ilib bin/hdo-transcript-indexer'",
    user        => hdo,
    environment => ['PATH=/usr/local/bin:/usr/bin:/bin', "MAILTO=${hdo::params::admin_email}"],
    require     => Class['build hdo-transcript-search indexer'],
    hour        => '3',
    minute      => '30'
  }


}
