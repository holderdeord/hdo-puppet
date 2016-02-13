class hdo::webapp(
  $listen            = '80',
  $server_name       = $::fqdn,
  $db_host           = undef,
  $db_port           = undef,
  $elasticsearch_url = undef,
  $ssl               = false
) {
  include hdo::common
  include hdo::params

  $webapp_root = $hdo::params::webapp_root
  $deploy_root = $hdo::params::deploy_root
  $app_root    = $hdo::params::app_root

  $shared_root = "${deploy_root}/shared"
  $config_root = "${deploy_root}/shared/config"
  $public_dir  = "${app_root}/public"

  file {
    [
      $deploy_root,
      $shared_root,
      $config_root
    ]:
    ensure => 'directory',
    mode   => '0775',
    owner  => 'hdo'
  }

  package { [
    'dpkg',
    'libxml2',
    'libxml2-dev',
    'libxslt1-dev',
    'imagemagick',
    'libpq-dev',
  ]:
    ensure => 'installed'
  }

  if ! defined(Class['passenger::nginx']) {
    class { 'passenger::nginx': port => $listen }
  }

  file { "${passenger::nginx::sites_dir}/${server_name}.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('hdo/nginx-app-vhost.conf.erb'),
    notify  => Service['nginx']
  }

  file { '/etc/profile.d/hdo-webapp.sh':
    ensure  => file,
    mode    => '0775',
    content => template('hdo/hdo-site-profile.sh')
  }

  file { "${config_root}/database.yml":
    owner   => 'hdo',
    mode    => '0600',
    content => template('hdo/database.yml'),
    require => File[$config_root]
  }

  file { "${config_root}/env.yml":
    owner   => 'hdo',
    mode    => '0600',
    content => template('hdo/env.yml'),
    require => File[$config_root]
  }

  logrotate::rule { 'hdo-site':
    path         => "${shared_root}/log/*.log",
    compress     => true,
    copytruncate => true,
    dateext      => true,
    ifempty      => false,
    missingok    => true
  }
}
