class munin::master(
    $package_name = $munin::params::server_package_name,
    $common_package = $munin::params::common_package_name,
    $package_ensure = "present") inherits munin::params {

    require hdo::backend::apache

 
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
      file {"/etc/apache2/sites-available/munin": 
          ensure => present,
          content => template("munin/apache.conf")
      }
      file {"/etc/apache2/sites-enabled/munin":
          ensure => "../sites-available/munin",
          require => File['/etc/apache2/sites-available/munin'],
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
