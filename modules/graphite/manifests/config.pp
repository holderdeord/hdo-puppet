class graphite::config inherits graphite::params {

  #
  # TODO: use postgres?
  #

  exec { 'create-graphite-db-django':
    command     => 'python manage.py syncdb --noinput',
    cwd         => "${graphite::params::docroot}/graphite",
    refreshonly => true,
    subscribe   => Class['graphite::install'],
    logoutput   => on_failure,
  }

  # need make sure apache can read this
  file { $graphite::params::storageroot:
    ensure  => directory,
    owner   => 'www-data',
    group   => 'www-data',
    recurse => true,
    require => Exec['create-graphite-db-django']
  }

  a2mod { 'headers':
    ensure => present
  }

  exec { 'create-graphite-htpasswd':
    command   => "htpasswd -b -c ${graphite::params::htpasswd_path} ${graphite::params::auth}",
    creates   => $graphite::params::htpasswd_path,
    require   => Class['apache'],
    logoutput => on_failure
  }

  apache::vhost { 'graphite.holderdeord.no':
    vhost_name    => '*',
    priority      => '70',
    port          => 80,
    template      => 'graphite/vhost.conf.erb',
    docroot       => $graphite::params::docroot,
    docroot_owner => $graphite::params::owner,
    notify        => Service['httpd'],
    require       => [File["${graphite::params::root}/storage"], A2mod['headers']],
  }

  #
  # set up carbon
  #

  file { "${graphite::params::root}/conf/storage-schemas.conf":
    ensure  => file,
    mode    => '0644',
    content => template('graphite/storage-schemas.conf.erb'),
    require => Class['graphite::install'],
    notify  => Service['carbon-cache'],
  }

  $carbon_user = $graphite::params::owner

  file { "${graphite::params::root}/conf/carbon.conf":
    ensure  => file,
    mode    => '0644',
    content => template('graphite/carbon.conf.erb'),
    require => Class['graphite::install'],
    notify  => Service['carbon-cache'],
  }

  file { '/etc/init.d/carbon-cache':
    ensure  => present,
    mode    => '0750',
    content => template('graphite/init-carbon-cache.erb')
  }

  logrotate::rule { 'graphite':
    path         => [
      "${graphite::params::storageroot}/log/*/*.log",
      "${graphite::params::storageroot}/log/*/*/*.log"
    ],
    compress     => true,
    copytruncate => true,
    dateext      => true,
    ifempty      => false,
    missingok    => true
  }

  service { 'carbon-cache':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => [
      File['/etc/init.d/carbon-cache'],
      File["${graphite::params::root}/conf/carbon.conf"],
      File["${graphite::params::root}/conf/storage-schemas.conf"]
    ]
  }
}
