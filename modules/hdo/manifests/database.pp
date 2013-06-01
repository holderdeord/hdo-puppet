class hdo::database(
  $primary_ip = undef,
  $standby_ip = undef
){

  if $primary_ip != undef and $standby_ip != undef {
    fail('hdo::database can not act as both master and slave')
  }

  include hdo::common

  if $primary_ip == undef {
    # this is the primary (or a standalone)
    # let's create the DB
    postgresql::db { "hdo_${hdo::params::environment}":
      user     => $hdo::params::db_username,
      password => postgresql_password($hdo::params::db_username, $hdo::params::db_password)
    }

    $postgres_password = $hdo::params::db_server_password
  } else {
    $postgres_password = undef
  }

  class { 'postgresql::server':
    # no idea why this is necessary - either the module isn't properly tested on ubuntu,
    # or something is non-standard about our VM image.

    service_name     => 'postgresql', # defaults to postgresql-9.1
    service_provider => init,         # defaults to upstart

    config_hash      => {
      'postgres_password'        => $postgres_password,
      'listen_addresses'         => '*',
      'ip_mask_allow_all_users'  => '0.0.0.0/0',
    }
  }

  include nagios::base

  file { "${nagios::base::checks_dir}/postgresql" :
    ensure => present,
    source => 'puppet:///modules/hdo/nagioschecks/postgresql',
    mode   => '0755',
    owner  => $nagios::base::user,
    group  => $nagios::base::user
  }

  file { "${postgresql::params::confdir}/postgresql_puppet_extras.conf":
    ensure  => file,
    owner   => 'postgres',
    content => template('hdo/postgresql_puppet_extras.conf.erb'),
    notify  => Service['postgresqld']
  }

  if $standby_ip != undef {
    postgresql::pg_hba_rule { 'allow slave to connect for streaming replication':
      type        => 'host',
      database    => 'replication',
      user        => 'postgres',
      address     => "${standby_ip}/32",
      auth_method => 'trust',
    }
  }

  if $primary_ip != undef {
    $backup_script = '/var/lib/postgresql/create-base-backup.sh'
    $recovery_conf = "${postgresql::params::datadir}/recovery.conf"

    file { $recovery_conf:
      ensure  => file,
      owner   => 'postgres',
      content => template('hdo/postgresql-recovery.conf.erb'),
      require => [Class['postgresql::server']]
    }

    file { $backup_script:
      ensure  => file,
      owner   => 'postgres',
      mode    => '0755',
      content => template('hdo/postgresql-create-base-backup.sh.erb'),
      require => [Class['postgresql::server']]
    }

    exec { 'create-base-backup':
      command => $backup_script,
      unless  => "ls ${postgresql::params::datadir}/backup*",
      user    => 'postgres',
      require => [File[$backup_script], File[$recovery_conf]],
    }
  }

  #
  # http://blog.gomiso.com/2011/07/28/adventures-in-scaling-part-2-postgresql/
  #
  package { ['ptop', 'pgtune']:
    ensure => installed
  }

}
