class passenger {
  include ruby
  include passenger::params

  file { '/home/hdo/nagioschecks/passenger':
    ensure => present,
    source => 'puppet:///modules/passenger/nagioschecks/passenger',
    owner  => 'hdo',
    group  => 'hdo',
    mode   => '0755',
  }

  package { 'libcurl4-openssl-dev':
    ensure => installed,
  }

  if ! defined(Package['build-essential']) {
    package { 'build-essential':
      ensure => installed,
    }
  }

  ruby::gem { 'passenger':
    version => $passenger::params::version,
    require => Package['build-essential']
  }
}
