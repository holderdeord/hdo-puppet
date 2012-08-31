class hdo::common {
  include hdo::params

  user { $hdo::params::user:
    ensure     => present,
    home       => "/home/${hdo::params::user}",
    managehome => true,
    shell      => '/bin/bash',
    groups     => $hdo::params::group
  }

  file { "/home/${hdo::params::user}":
    ensure  => directory,
    owner   => $hdo::params::user,
    require => User[$hdo::params::user],
  }

  # Looks like vagrant doesn't create the puppet group by default?
  group { 'puppet':
    ensure => present
  }

}
