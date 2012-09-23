class munin::master(
  $package_name   = $munin::params::server_package_name,
  $common_package = $munin::params::common_package_name,
  $package_ensure = "present",
  $docroot        = $munin::params::docroot,
  $servername     = $munin::params::servername,
  $port           = $munin::params::port,
  $serveradmin    = $munin::params::serveradmin) inherits munin::params {

  include apache
     
  define packages() {
    package { $package_name: ensure => $package_ensure, }
    package { $common_package: ensure => $package_ensure, }
  }

  define config(){
    file {"/etc/munin/munin.conf": 
      ensure  => present,
      content => template("munin/munin.conf")
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
    }
  }

  config{"configfiles":
    notify  => Exec['graceful'],
    require => Packages['muninserver'],
  }

  packages{"muninserver":
    notify => Exec['graceful'],
  }
    
  exec {"graceful":
    command => "/usr/sbin/apache2ctl graceful",
    refreshonly => true,
  }
}
