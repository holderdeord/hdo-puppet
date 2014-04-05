class hdo::collectd(
  $version  = '5.3.0',
  $graphite = 'graphite.holderdeord.no'
) {

  class { '::collectd':
    version      => $version,
    purge        => true,
    recurse      => true,
    purge_config => true,
    require      => [Apt::Ppa['ppa:vbulax/collectd5'], Class['apt::update']],
  }

  # make sure config is not world readable
  exec { 'fix-collectd-plugin-permissions':
    command => "chmod 0740 ${::collectd::params::plugin_conf_dir}",
    require => File[$::collectd::params::plugin_conf_dir],
  }

  class { '::collectd::plugin::write_graphite':
    graphitehost      => $graphite,
    separateinstances => true,
  }

  class { '::collectd::plugin::syslog': log_level => 'debug' }
  class { '::collectd::plugin::cpu': }
  class { '::collectd::plugin::df': }
  class { '::collectd::plugin::disk': }
  class { '::collectd::plugin::entropy': }
  class { '::collectd::plugin::interface': }
  class { '::collectd::plugin::irq': }
  class { '::collectd::plugin::load': }
  class { '::collectd::plugin::memory': }
  class { '::collectd::plugin::processes': }
  class { '::collectd::plugin::swap': }
  class { '::collectd::plugin::users': }

}
