class graphite {
  include apache
  include apache::mod::python

  include graphite::install
  include graphite::config

  class { 'grafana':
    root => "${graphite::params::docroot}/grafana"
  }
}
