class passenger::apache inherits passenger {
  include ::apache

  $passenger_module = "${passenger::params::root}/ext/apache2/mod_passenger.so"

  package {
    'apache2-prefork-dev':
      ensure => installed;
    'libapr1-dev':
      ensure => installed;
    'libaprutil1-dev':
      ensure => installed;
  }

  # We don't use libapache2-mod-passenger I suspect because it's too old?
  exec { 'install-passenger-apache':
    # Real path is /var/lib/gems/1.9.1/gems/passenger-3.0.14/bin, but
    # the command is also installed (hardlink?) in /usr/local/bin,
    # so it's definitely more robust to rely on the /usr/local/bin copy
    path    => ['/bin', '/usr/bin', '/usr/local/bin'],
    command => 'passenger-install-apache2-module --auto && cd /etc/apache2/mods-enabled',
    creates => $passenger_module,
    require => [
      Ruby::Gem['passenger'],
      Package['apache2-prefork-dev'],
      Package['libapr1-dev'],
      Package['libaprutil1-dev'],
      Package['libcurl4-openssl-dev']
    ],
    logoutput => on_failure
  }

  file { '/etc/apache2/conf.d/passenger.conf':
    owner   => root,
    mode    => '0644',
    content => template('passenger/apache.conf.erb'),
    require => [Ruby::Gem['passenger'], Exec['install-passenger-apache']],
    notify  => Service['httpd']
  }

}