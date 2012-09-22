class munin::master(
    $package_name = $munin::params::server_package_name,
    $common_package = $munin::params::common_package_name,
    $package_ensure = "present") inherits munin::params {

    include apache

 
    #notice("Dette er i master")
    #notice("package_name $package_name")
    #notice("common_package $common_package")
    
     
    define packages() {
        package { $package_name: ensure => present, }
        package { $common_package: ensure => present }
    }

    define config(){
      file {"/etc/munin/munin.conf": 
          #notice("Dette er i munin.conf tempate definisjonen"),
          ensure => present,
          content => template("munin/munin.conf")
      }

      apache::vhost { 'munin.holderdeord.no':
        vhost_name    => '*',
        port          => 80,
        priority      => '99',
        servername    => 'munin.holderdeord.no',
        serveradmin   => 'teknisk@holderdeord.no',
        template      => 'munin/munin_vhost.conf.erb',
        docroot       => $hdo::params::public_dir,
        docroot_owner => 'hdo',
        docroot_group => 'hdo',
        options       => '-MultiViews -Indexes',
        notify        => Service['httpd'],
        #require       => [A2mod['rewrite'], User['hdo']]
      }

    }

    config{"configfiles":
        notify => Exec['graceful'],
    }

    packages{"muninserver":
        notify => Exec['graceful'],
    }
    
    exec {"graceful":
        command => "/usr/sbin/apache2ctl graceful",
        refreshonly => true,
    }


}
