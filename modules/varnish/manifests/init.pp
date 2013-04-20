class varnish(
  $backends       = [{host => '127.0.0.1', port => 8080}],
  $listen_address = '',
  $listen_port    = 6081,
  $thread_min     = 400,
  $thread_max     = 5000,
  $thread_timeout = 30,
  $storage_type   = 'malloc',
  $storage_size   = '12G',
  $ttl            = 60,
  $thread_pools   = $::processorcount,
  $sess_workspace = 131072,
  $sess_timeout   = 3,
  $ensure         = 'present'
) {

  if !($ensure in ['present', 'absent']) {
    fail("invalid ensure, expected present or absent: ${ensure}")
  }

  if size($backends) < 1 {
    fail('must specify at least one backend')
  }

  package { 'varnish':
    ensure => $ensure,
  }

  # Make sure suggested TCP/IP perf tuning parameters are there
  file { '/etc/sysctl.conf':
    ensure => 'present',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => [
      "puppet:///modules/varnish/sysctl.conf.${::lsbdistcodename}",
      'puppet:///modules/varnish/sysctl.conf',
    ],
  }

  file { '/usr/share/varnish/purge-cache':
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/varnish/purge-cache',
    require => Package['varnish'],
  }

  file { '/etc/varnish/default.vcl':
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('varnish/default.vcl.erb'),
    require => Package['varnish'],
    notify  => Service['varnish'],
  }

  exec { 'update-sysctl':
    command     => '/sbin/sysctl -p /etc/sysctl.conf',
    subscribe   => File['/etc/sysctl.conf'],
    refreshonly => true,
  }

  $service_ensure = $ensure ? {
    'present' => running,
    'absent'  => stopped
  }

  service { 'varnish':
    ensure    => $service_ensure,
    subscribe => Package['varnish'],
    require   => [
      Package['varnish'],
      File['/etc/sysctl.conf'],
      File['/etc/varnish/default.vcl']
    ],
  }

  file { '/etc/default/varnish':
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('varnish/debian-defaults.erb'),
    require => Package['varnish'],
    notify  => Service['varnish'],
  }

  include nagios::base

  # this check is very naive
  # TODO: look at https://www.varnish-cache.org/utilities

  file { "${nagios::base::checks_dir}/varnish":
    ensure => file,
    owner  => $nagios::base::user,
    mode   => '0700',
    source => 'puppet:///modules/varnish/nagioschecks/varnish'
  }

  munin::plugin { [
    'varnish_backend_traffic',
    'varnish_expunge',
    'varnish_hit_rate',
    'varnish_memory_usage',
    'varnish_objects',
    'varnish_request_rate',
    'varnish_threads',
    'varnish_transfer_rates',
    'varnish_uptime'
    ]:
      plugin_name => 'varnish_',
  }

}
