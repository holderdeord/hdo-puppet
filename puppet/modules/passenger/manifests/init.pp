class passenger {
  include ruby
  include passenger::params

  package { 'libcurl4-openssl-dev':
    ensure => installed,
  }

  ruby::gem { 'passenger':
    version => $passenger::params::version
  }
}
