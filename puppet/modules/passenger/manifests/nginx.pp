class passenger::nginx inherits passenger {
  $root        = '/opt/nginx'
  $init_script = '/etc/init.d/nginx'
  $config_dir = "${root}/conf"
  $log_dir    = "${root}/logs"
  $sites_dir  = "${config_dir}/sites-enabled"
  $config     = "${config_dir}/nginx.conf"
  $daemon     = "${root}/sbin/nginx"

  exec { 'install-passenger-nginx':
    path      => ['/bin', '/usr/bin', '/usr/local/bin'],
    command   => "passenger-install-nginx-module --extra-configure-flags='--with-http_stub_status_module' --auto --auto-download --prefix ${root}",
    creates   => $root,
    require   => [Ruby::Gem['passenger'], Package['libcurl4-openssl-dev']],
    logoutput => on_failure,
    timeout   => 600
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

}
