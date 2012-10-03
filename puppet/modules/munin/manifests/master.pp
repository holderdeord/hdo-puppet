class munin::master(
  $package_name   = $munin::params::server_package_name,
  $common_package = $munin::params::common_package_name,
  $package_ensure = 'present',
  $docroot        = $munin::params::docroot,
  $servername     = $munin::params::servername,
  $port           = $munin::params::port,
  $serveradmin    = $munin::params::serveradmin) inherits munin::params {

  include apache

  $package_list = [ $package_name, $common_package ]

  package { $package_list: }

  Package { ensure => present }

  file { '/etc/munin/munin.conf':
    ensure  => present,
    content => template('munin/munin.conf'),
    notify => Exec['graceful'],
    require => Package[$package_list],
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

  exec { 'graceful':
    command     => '/usr/sbin/apache2ctl graceful',
    refreshonly => true,
  }
}
