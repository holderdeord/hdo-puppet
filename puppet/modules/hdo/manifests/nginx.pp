class hdo::nginx {
  include hdo::params

  $public_dir        = $hdo::params::public_dir
  $log_dir           = '/var/log/nginx'
  $server_name       = ''
  $app_server_socket = $hdo::params::unicorn_socket

  package { 'nginx':
    ensure => installed,
  }

  service { 'nginx':
    ensure  => running,
    require => Package['nginx']
  }

  file { '/etc/nginx/nginx.conf':
    ensure  => file,
    content => template('hdo/nginx.conf.erb'),
    notify  => Service['nginx'],
    require => Package['nginx']
  }

}