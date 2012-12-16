class munin::master(
  $package_name   = $munin::params::server_package_name,
  $common_package = $munin::params::common_package_name,
  $package_ensure = 'present',
  $docroot        = $munin::params::docroot,
  $servername     = $munin::params::servername,
  $port           = $munin::params::port,
  $serveradmin    = $munin::params::serveradmin,
  $auth           = $munin::params::auth
) inherits munin::params {

  include apache

  $package_list = [
    $package_name,
    $common_package
  ]

  package { $package_list: ensure => present }

  # TODO: service resource for munin-master + restart on config change
  file { '/etc/munin/munin.conf':
    ensure  => present,
    content => template('munin/munin.conf'),
    notify  => Service['httpd'],
    require => Package[$package_list],
  }

  $htpasswd_path = '/etc/apache2/munin.htpasswd'

  exec { 'create-munin-htpasswd':
    command   => "htpasswd -b -s -c ${htpasswd_path} ${auth}",
    creates   => $htpasswd_path,
    require   => Class['apache'],
    logoutput => on_failure
  }

  #
  # use our custom apache config
  #

  file { '/etc/apache2/conf.d/munin':
    ensure => absent
  }

  apache::vhost { 'munin.holderdeord.no':
    vhost_name    => '*',
    port          => $port,
    priority      => '99',
    servername    => $servername,
    serveradmin   => $serveradmin,
    template      => 'munin/munin_vhost.conf.erb',
    docroot       => $docroot,
    docroot_owner => 'munin',
    docroot_group => 'munin',
    notify        => Service['httpd'],
    require       => Package[$package_list],
  }
}
