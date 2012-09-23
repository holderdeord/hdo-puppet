class munin::master(
  $package_name   = $munin::params::server_package_name,
  $common_package = $munin::params::common_package_name,
  $package_ensure = "present") inherits munin::params {

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
      port          => 80,
      priority      => '99',
      servername    => 'munin.holderdeord.no',
      serveradmin   => 'kontakt@holderdeord.no',
      template      => 'munin/munin_vhost.conf.erb',
      docroot       => $hdo::params::public_dir,
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
