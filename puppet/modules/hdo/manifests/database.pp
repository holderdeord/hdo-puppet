class hdo::database {

  include hdo::common

  class { 'postgresql::server':
    # no idea why this is necessary - either the module isn't properly tested on ubuntu,
    # or something is non-standard about our VM image.

    service_name     => 'postgresql', # defaults to postgresql-9.1
    service_provider => init,         # defaults to upstart

    config_hash      => {
        'postgres_password' => $hdo::params::db_server_password,
    }
  }

  postgresql::db { "hdo_${hdo::params::environment}":
    user     => $hdo::params::db_username,
    password => postgresql_password($hdo::params::db_username, $hdo::params::db_password)
  }

  file { '/home/hdo/nagioschecks/postgresql':
    ensure => present,
    source => 'puppet:///modules/hdo/nagioschecks/postgresql',
    mode   => '0755',
    owner  => 'hdo',
    group  => 'hdo'
  }

  #
  # http://blog.gomiso.com/2011/07/28/adventures-in-scaling-part-2-postgresql/
  #
  package { 'pgtune':
    ensure => installed
  }

}
