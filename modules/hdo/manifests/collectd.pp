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

  class { '::collectd::plugin::write_graphite':
    graphitehost      => $graphite,
    separateinstances => true,
  }

  class { '::collectd::plugin::cpu': }
  class { '::collectd::plugin::df': }
  class { '::collectd::plugin::disk': }
  class { '::collectd::plugin::entropy': }
  class { '::collectd::plugin::interface': }
  class { '::collectd::plugin::irq': }
  class { '::collectd::plugin::load': }
  class { '::collectd::plugin::memory': }
  class { '::collectd::plugin::ntpd': }
  class { '::collectd::plugin::processes': }
  class { '::collectd::plugin::swap': }
  class { '::collectd::plugin::syslog': log_level => 'debug' }
  class { '::collectd::plugin::users': }

  include nagios::base

  file { "${nagios::base::checks_dir}/collectd" :
    ensure => present,
    source => 'puppet:///modules/hdo/nagioschecks/collectd',
    mode   => '0755',
    owner  => $nagios::base::user,
    group  => $nagios::base::user
  }

  collectd::plugin::tail::file { 'auth-log':
    filename => '/var/log/auth.log',
    instance => 'auth',
    matches  => [
      {
        regex    => '\\<sshd[^:]*: Accepted publickey for [^ ]+ from\\>',
        dstype   => 'CounterInc',
        type     => 'counter',
        instance => 'auth-publickey',
      },
      {
        regex    => '\\<sshd[^:]*: Invalid user [^ ]+ from\\>',
        dstype   => 'CounterInc',
        type     => 'counter',
        instance => 'auth-invalid-user',
      },
      {
        regex    => '\\<sshd[^:]*: Failed password\\>',
        dstype   => 'CounterInc',
        type     => 'counter',
        instance => 'auth-failed-password',
      }
    ]
  }

}
