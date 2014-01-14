class passenger::apache inherits passenger {
  include ::apache

  $passenger_module = "${passenger::params::root}/buildout/apache2/mod_passenger.so"

  package {
    'apache2-prefork-dev':
      ensure => installed;
    'libapr1-dev':
      ensure => installed;
    'libaprutil1-dev':
      ensure => installed;
  }

  exec { 'install-passenger-apache':
    path      => ['/bin', '/usr/bin', '/usr/local/bin'],
    command   => 'bash -l -c "passenger-install-apache2-module --auto && cd /etc/apache2/mods-enabled"',
    creates   => $passenger_module,
    require   => [
      Ruby::Gem['passenger'],
      Package['apache2-prefork-dev'],
      Package['libapr1-dev'],
      Package['libaprutil1-dev'],
      Package['libcurl4-openssl-dev']
    ],
  }

  file { '/etc/apache2/conf.d/passenger.conf':
    owner   => root,
    mode    => '0644',
    content => template('passenger/apache.conf.erb'),
    require => [Ruby::Gem['passenger'], Exec['install-passenger-apache']],
    notify  => Service['httpd']
  }

}