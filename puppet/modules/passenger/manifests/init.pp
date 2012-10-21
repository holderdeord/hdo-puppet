class passenger {
  include ruby
  include passenger::params

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
