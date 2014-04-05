class hdo::collectd::default {
  class { 'hdo::collectd':
    graphite => 'graphite.holderdeord.no'
  }
}