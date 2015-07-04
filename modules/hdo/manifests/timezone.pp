class hdo::timezone {
  file { '/etc/timezone':
    ensure  => present
    content => "Europe/Berlin\n"
    notify  => Exec['reconfigure-tzdata']
  }

  exec { 'reconfigure-tzdata':
    command     => '/usr/sbin/dpkg-reconfigure --frontend noninteractive tzdata',
    refreshonly => true
  }
}