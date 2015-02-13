class hdo::collectd::default($version = '5.3.0') {
  class { 'hdo::collectd':
    version  => $version,
    graphite => 'graphite.holderdeord.no'
  }
}
