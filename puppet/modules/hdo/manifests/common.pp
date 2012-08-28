class hdo::common {

  user { 'hdo':
    ensure     => present,
    home       => '/home/hdo',
    managehome => true,
    password   => '7ba6c44a47bd64d32fd2360d70087deaf222d55e',
    shell      => '/bin/bash',
    groups     => 'sudo'
  }

  file { '/home/hdo':
    ensure  => directory,
    owner   => 'hdo',
    require => User['hdo'],
  }

  # Looks like vagrant doesn't create the puppet group by default?
  group { 'puppet':
    ensure => present
  }

}
