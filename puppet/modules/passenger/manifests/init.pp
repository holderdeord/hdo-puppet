class passenger {
  include ruby
  include passenger::params

  ruby::gem { 'passenger':
    version => $passenger::params::version
  }
}
