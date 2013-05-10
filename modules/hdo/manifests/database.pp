class hdo::database(
  $master_host = undef,
  $slave_host = undef
){

  include hdo::common

  class { 'postgresql::server':
    # no idea why this is necessary - either the module isn't properly tested on ubuntu,
    # or something is non-standard about our VM image.

    service_name     => 'postgresql', # defaults to postgresql-9.1
    service_provider => init,         # defaults to upstart

    config_hash      => {
        'postgres_password'        => $hdo::params::db_server_password,
        'listen_addresses'         => '*',
        'ip_mask_allow_all_users'  => '0.0.0.0/0',
    }
  }

  postgresql::db { "hdo_${hdo::params::environment}":
    user     => $hdo::params::db_username,
    password => postgresql_password($hdo::params::db_username, $hdo::params::db_password)
  }

  include nagios::base

  file { "${nagios::base::checks_dir}/postgresql" :
    ensure => present,
    source => 'puppet:///modules/hdo/nagioschecks/postgresql',
    mode   => '0755',
    owner  => $nagios::base::user,
    group  => $nagios::base::user
  }

  file { '/etc/postgresql/9.1/main/postgresql_puppet_extras.conf':
    ensure  => file,
    owner   => 'postgres',
    source  => 'puppet:///modules/hdo/db/postgresql_puppet_extras.conf',
  }

  if $master_host != undef and $slave_host != undef {
    fail('hdo::database can not act as both master and slave')
  }

  if $slave_host != undef {
    # this is the master - let's create the DB

    postgresql::pg_hba_rule { 'allow slave to connect for streaming replication':
      type        => 'host',
      database    => 'replication',
      user        => 'postgres',
      address     => "${slave_host}/32",
      auth_method => 'trust',
    }
  }

  if $master_host != undef {
    file { '/var/lib/postgresql/9.1/main/recovery.conf':
      ensure  => file,
      owner   => 'postgres',
      content => template('hdo/postgresql-recovery.conf.erb')
    }
  }

  #
  # http://blog.gomiso.com/2011/07/28/adventures-in-scaling-part-2-postgresql/
  #
  package { 'pgtune':
    ensure => installed
  }

}
