class passenger::nginx($port = 80) inherits passenger {
  $root        = "/opt/nginx-passenger${passenger::params::version}-ruby${ruby::version}"
  $init_script = '/etc/init.d/nginx'
  $config_dir  = "${root}/conf"
  $log_dir     = "${root}/logs"
  $sites_dir   = "${config_dir}/sites-enabled"
  $config      = "${config_dir}/nginx.conf"
  $mime_types  = "${config_dir}/mime.types"
  $daemon      = "${root}/sbin/nginx"
  $listen      = $port

  exec { 'install-passenger-nginx':
    command   => "bash -l -c 'passenger-install-nginx-module --extra-configure-flags=\'--with-http_stub_status_module\' --auto --auto-download --prefix ${root}'",
    creates   => $root,
    require   => [Ruby::Gem['passenger'], Package['libcurl4-openssl-dev']],
    timeout   => 900
  }

  file { '/opt/nginx':
    ensure  => $root,
    require => Exec['install-passenger-nginx'],
    notify  => Service['nginx']
  }

  include nagios::base

  file { "${nagios::base::checks_dir}/nginx":
    ensure => present,
    owner  => $nagios::base::user,
    group  => $nagios::base::user,
    mode   => '0700',
    source => 'puppet:///modules/passenger/nagioschecks/nginx'
  }

  file { $init_script:
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template('passenger/nginx-init.sh.erb'),
    require => Exec['install-passenger-nginx']
  }

  file { $config:
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('passenger/nginx.conf.erb'),
    require => Exec['install-passenger-nginx'],
    notify  => Service['nginx']
  }

  file { $mime_types:
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => 'puppet:///modules/passenger/nginx/mime.types',
    require => Exec['install-passenger-nginx'],
    notify  => Service['nginx']
  }

  file { $sites_dir:
    ensure  => directory,
    owner   => root,
    group   => root,
    require => Exec['install-passenger-nginx']
  }

  service { 'nginx':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => File[$init_script],
  }

  logrotate::rule { 'nginx':
    path         => "${log_dir}/*.log",
    compress     => true,
    copytruncate => true,
    dateext      => true,
    ifempty      => false,
    missingok    => true
  }

  file { "${sites_dir}/status.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('passenger/nginx-status-vhost.conf.erb'),
    notify  => Service['nginx']
  }

  class { 'munin::nginx': port => $listen }

  class { 'collectd::plugin::nginx':
    url     => "http://localhost:${listen}/nginx_status",
    require => Class['hdo::collectd'],
    notify  => Service['collectd'],
  }
}
