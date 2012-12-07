class statsd(
  $ensure        = 'running',
  $version       = false,
  $port          = 8125,
  $graphite_host = 'localhost',
  $graphite_port = 2003,
) {

  include nodejs

  nodejs::npm { 'statsd':
    version => $version,
    notify  => Service['statsd'],
  }

  file { '/etc/statsd':
    ensure => directory
  }

  file { '/etc/statsd/config.js':
    ensure  => file,
    mode    => '0644',
    content => template('statsd/config.js.erb'),
    require => File['/etc/statsd'],
    notify  => Service['statsd'],
  }

  file { '/var/log/statsd':
    ensure => directory,
    group  => 'nogroup',
    mode   => '0770',
  }

  file { '/usr/share/statsd':
    ensure => directory,
    group  => 'nogroup',
  }

  file { '/usr/share/statsd/start.sh':
    ensure  => file,
    mode    => '0744',
    owner   => 'nobody',
    group   => 'nogroup',
    content => template('statsd/start.sh'),
    require => File['/usr/share/statsd'],
    notify  => Service['statsd'],
  }

  file { '/etc/init/statsd.conf':
    ensure  => file,
    content => template('statsd/upstart.conf'),
    notify  => Service['statsd'],
  }

  service { 'statsd':
    ensure     => $ensure,
    enable     => $ensure,
    provider   => 'upstart',
    require    => [File['/etc/init/statsd.conf'], File['/var/log/statsd']]
  }


}