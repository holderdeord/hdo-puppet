class nagios::monitor {
  package { [ 'nagios3', 'nagios-plugins' ]: ensure => installed }

  service { 'nagios':
    ensure    => running,
    hasstatus => true,
    enable    => true,
    subscribe => [ Package['nagios3'], Package['nagios-plugins'] ],
  }

  # collect resources and populate /etc/nagios/nagios_*.cfg
  Nagios_host    <<||>> { notify => Service['nagios'] }
  Nagios_service <<||>> { notify => Service['nagios'] }

  $htpasswd_path = '/etc/nagios3/htpasswd.users'
  $auth          = hiera('basic_auth', 'hdo hdo')

  exec { 'create-nagios-htpasswd':
    command   => "htpasswd -b -s -c ${htpasswd_path} ${auth}",
    creates   => $htpasswd_path,
    require   => Package['nagios3'],
    logoutput => on_failure
  }

  #
  # use our custom apache config
  #

  file { '/etc/apache2/conf.d/nagios3.conf':
    ensure => absent
  }

  a2mod { 'rewrite':
    ensure => present
  }

  apache::vhost { 'nagios.holderdeord.no':
    vhost_name    => '*',
    port          => 80,
    priority      => '60',
    servername    => 'nagios.holderdeord.no',
    serveradmin   => 'nagios.holderdeord.no',
    template      => 'nagios/nagios_vhost.conf.erb',
    docroot       => '/usr/share/nagios3/htdocs',
    docroot_owner => 'root',
    docroot_group => 'root',
    notify        => Service['httpd'],
    require       => Package['nagios3'],
  }

}
