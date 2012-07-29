class passenger {

  $passenger_ruby          = "/usr/bin/ruby1.9.1"
  $passenger_root          = "/usr/lib/phusion-passenger"
  $passenger_min_instances = 3
  $passenger_max_pool_size = 10
  $passenger_max_instances_per_app = 10 # only running one app
  $passenger_pool_idle_time = 300

  include apache
  include ruby

  package {
    "apache2-prefork-dev":
      ensure => "installed";
    "libapr1-dev":
      ensure => "installed";
    "libaprutil1-dev":
      ensure => "installed";
  }

  ruby::gem { "passenger": }

  # We don't use libapache2-mod-passenger I suspect because it's too old?
  exec { "passenger-apache":
    # Real path is /var/lib/gems/1.9.1/gems/passenger-3.0.14/bin, but
    # the command is also installed (hardlink?) in /usr/local/bin,
    # so it's definitely more robust to rely on the /usr/local/bin copy
    path    => ["/bin", "/usr/bin", "/usr/local/bin"],
    command => "passenger-install-apache2-module --auto && cd /etc/apache2/mods-enabled",
    creates => "/var/lib/gems/1.9.1/gems/passenger-3.0.14/ext/apache2/mod_passenger.so",
    require => [
      Ruby::Gem["passenger"],
      Package["apache2-prefork-dev"],
      Package["libapr1-dev"],
      Package["libaprutil1-dev"],
    ],
  }

  file { "/etc/apache2/conf.d/passenger.conf":
    owner   => root,
    mode    => 644,
    content => template("passenger/passenger.conf.erb"),
    require => Ruby::Gem['passenger'],
    notify  => Service['httpd']
  }

}
