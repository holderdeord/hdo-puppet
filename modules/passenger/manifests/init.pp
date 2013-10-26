class passenger {
  include ruby
  include passenger::params
  include nagios::base

  file { "${nagios::base::checks_dir}/passenger" :
    ensure => present,
    source => 'puppet:///modules/passenger/nagioschecks/passenger',
    owner  => $nagios::base::user,
    group  => $nagios::base::user,
    mode   => '0755',
  }

  package { 'libcurl4-openssl-dev': ensure => installed }

  if ! defined(Package['build-essential']) {
    package { 'build-essential': ensure => installed }
  }

  ruby::gem { 'passenger':
    version => $passenger::params::version,
    require => [Package['build-essential'], Class['ruby']],
  }
}
