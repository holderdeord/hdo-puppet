class nagios::monitor {
  package { [ 'nagios3', 'nagios-plugins' ]: ensure => installed }

  service { 'nagios':
    ensure    => running,
    hasstatus => true,
    enable    => true,
    subscribe => [ Package['nagios3'], Package['nagios-plugins'] ],
  }

  $htpasswd_path = '/etc/nagios/htpasswd.users'
  $auth          = hiera('basic_auth', 'hdo hdo')

  exec { 'create-nagios-htpasswd':
    command   => "htpasswd -b -s -c ${htpasswd_path} ${auth}",
    creates   => $htpasswd_path,
    require   => Package['nagios3'],
    logoutput => on_failure
  }

  # collect resources and populate /etc/nagios/nagios_*.cfg
  Nagios_host    <<||>> { notify => Service['nagios'] }
  Nagios_service <<||>> { notify => Service['nagios'] }
}
