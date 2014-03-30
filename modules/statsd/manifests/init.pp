class statsd(
  $ensure        = 'running',
  $version       = '0.7.1',
  $port          = 8125,
  $graphite_host = 'localhost',
  $graphite_port = 2003,
) {

  class { 'nodejs': manage_repo => true }

  package { 'statsd':
    ensure   => $version,
    provider => 'npm',
    notify   => Service['statsd'],
    require  => Package['nodejs'],
  }

  file { '/etc/statsd':
    ensure => directory
  }

  include nagios::base

  file { "${nagios::base::checks_dir}/statsd" :
    ensure => present,
    mode   => '0755',
    owner  => 'hdo',
    group  => 'hdo',
    source => 'puppet:///modules/statsd/nagioschecks/statsd'
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
    group  => ['nogroup', 'adm'],
    mode   => '0770',
  }

  logrotate::rule { 'statsd':
    path         => '/var/log/statsd/*.log',
    compress     => true,
    copytruncate => true,
    dateext      => true,
    ifempty      => false,
    missingok    => true
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
    provider   => 'upstart',
    require    => [File['/etc/init/statsd.conf'], File['/var/log/statsd']]
  }
}
