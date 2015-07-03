class passenger::nginx(
  $port = 80,
  $nagios = true,
  $munin  = true,
  $collectd = true,
  $purge = false,
  $pingdom = false
) inherits passenger {
  $root        = "/opt/nginx-passenger${passenger::params::version}-ruby${ruby::version}"
  $init_script = '/etc/init.d/nginx'
  $config_dir  = "${root}/conf"
  $log_dir     = "${root}/logs"
  $ssl_dir     = "${root}/ssl"
  $sites_dir   = "${config_dir}/sites-enabled"
  $tmp_dir     = '/tmp/nginx'
  $config      = "${config_dir}/nginx.conf"
  $mime_types  = "${config_dir}/mime.types"
  $daemon      = "${root}/sbin/nginx"
  $listen      = $port
  $pingdom_dir = "${hdo::params::webapp_root}/pingdom"

  if ($purge) {
    $cache_purge_dir = '/opt/ngx_cache_purge'
    $extra_flags     = "--add-module=${cache_purge_dir}"

    exec { 'clone ngx_cache_purge':
      command => "git clone https://github.com/FRiCKLE/ngx_cache_purge ${cache_purge_dir}",
      creates => $cache_purge_dir,
      require => [Package['git-core']],
      before  => Exec['install-passenger-nginx'],
    }
  } else {
    $extra_flags = ''
  }

  if ($pingdom) {
    exec { 'clone pingdom-os-stats':
      command => "git clone git://github.com/jarib/pingdom-os-stats ${pingdom_dir}",
      user    => hdo,
      creates => $pingdom_dir,
      require => [Package['git-core'], File[$hdo::params::webapp_root]]
    }

    exec { 'npm install pingdom-os-stats':
      command => 'npm install',
      user    => hdo,
      cwd     => $pingdom_dir,
      creates => "${pingdom_dir}/node_modules",
      require => Exec['clone pingdom-os-stats']
    }

  }

  exec { 'install-passenger-nginx':
    command => "bash -l -c 'passenger-install-nginx-module --extra-configure-flags=\"${extra_flags} --with-http_stub_status_module --prefix=${root}\" --auto --auto-download --prefix=${root}'",
    creates => $root,
    require => [Ruby::Gem['passenger'], Package['libcurl4-openssl-dev']],
    timeout => 900
  }

  file { '/opt/nginx':
    ensure  => $root,
    require => Exec['install-passenger-nginx'],
    notify  => Service['nginx']
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

  file { $tmp_dir:
    ensure  => directory,
    owner   => root,
    group   => root,
    require => Exec['install-passenger-nginx']
  }

  file { $ssl_dir:
    ensure  => directory,
    owner   => root,
    group   => 'ssl-cert',
    require => Exec['install-passenger-nginx']
  }

  file { "${ssl_dir}/private":
    ensure  => directory,
    owner   => root,
    group   => 'ssl-cert',
    mode    => '0640'
    require => Exec['install-passenger-nginx']
  }

  service { 'nginx':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => [File[$init_script], File[$tmp_dir]],
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

  if $nagios == true {
    include nagios::base

    file { "${nagios::base::checks_dir}/nginx":
      ensure => present,
      owner  => $nagios::base::user,
      group  => $nagios::base::user,
      mode   => '0700',
      source => 'puppet:///modules/passenger/nagioschecks/nginx'
    }
  }

  if $munin == true {
    class { 'munin::nginx': port => $listen }
  }

  if $collectd == true {
    class { 'collectd::plugin::nginx':
      url     => "http://localhost:${listen}/nginx_status",
      require => Class['hdo::collectd'],
      notify  => Service['collectd'],
    }
  }



}
