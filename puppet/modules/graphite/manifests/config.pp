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
  file { "${graphite::params::root}/storage":
    ensure  => directory,
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0644',
    recurse => true,
    require => Exec['create-graphite-db-django']
  }

  apache::vhost { 'graphite.holderdeord.no':
    vhost_name    => '*',
    priority      => '70',
    port          => 80,
    template      => 'graphite/vhost.conf.erb',
    docroot       => $graphite::params::docroot,
    docroot_owner => $graphite::params::owner,
    notify        => Service['httpd'],
    require       => File["${graphite::params::root}/storage"],
  }

  #
  # set up carbon
  #

  # just copying the example config for now
  file { "${graphite::params::root}/conf/storage-schemas.conf":
    ensure  => file,
    mode    => '0644',
    source  => "${graphite::params::root}/conf/storage-schemas.conf.example",
    require => Class['graphite::install'],
  }

  $carbon_user = $graphite::params::owner

  file { "${graphite::params::root}/conf/carbon.conf":
    ensure  => file,
    mode    => '0644',
    content => template('graphite/carbon.conf.erb'),
    require => Class['graphite::install'],
  }

  file { '/etc/init.d/carbon-cache':
    ensure  => present,
    mode    => '0750',
    content => template('graphite/init-carbon-cache.erb')
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

