class hdo::database(
  $primary_ip   = undef,
  $standby_ip   = undef,
  $munin        = false,
  $collectd     = false,
  $local_backup = 'absent',
){

  if $primary_ip != undef and $standby_ip != undef {
    fail('hdo::database can not act as both master and slave')
  }

  include hdo::common

  $db_name     = "hdo_${hdo::params::environment}"
  $backup_root = "${hdo::params::home}/pg-backups"

  if $primary_ip == undef {
    # this is the primary (or a standalone)
    # let's create the DB
    postgresql::db { $db_name:
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

  if $munin {
    munin::plugin { 'postgres_bgwriter':                                                 }
    munin::plugin { 'postgres_cache_ALL':        plugin_name => 'postgres_cache_'        }
    munin::plugin { 'postgres_checkpoints':                                              }
    munin::plugin { 'postgres_connections_ALL':  plugin_name => 'postgres_connections_'  }
    munin::plugin { 'postgres_connections_db':                                           }
    munin::plugin { 'postgres_locks_ALL':        plugin_name => 'postgres_locks_'        }
    munin::plugin { 'postgres_querylength_ALL':  plugin_name => 'postgres_querylength_'  }
    munin::plugin { 'postgres_scans_ALL':        plugin_name => 'postgres_scans_'        }
    munin::plugin { 'postgres_size_ALL':         plugin_name => 'postgres_size_'         }
    munin::plugin { 'postgres_transactions_ALL': plugin_name => 'postgres_transactions_' }
    munin::plugin { 'postgres_tuples_ALL':       plugin_name => 'postgres_tuples_'       }
    munin::plugin { 'postgres_users':                                                    }
    munin::plugin { 'postgres_xlog':                                                     }

    package { 'libdbd-pg-perl': ensure => installed, }
  }

  $hack = '' # to avoid syntax error / linting bug

  if $collectd {
    class { 'collectd::plugin::postgresql':
      databases => { "${db_name}${hack}" => {
          'host'     => 'localhost',
          'user'     => $hdo::params::db_username,
          'password' => $hdo::params::db_password,
          'sslmode'  => 'prefer',
          'query'    => ['backends', 'transactions', 'query_plans', 'queries', 'table_states', 'disk_io', 'disk_usage'],
        }
      },
      require   => Class['hdo::collectd'],
      notify    => Service['collectd'],
    }
  }

  $local_backup_script = '/var/lib/postgresql/postgresql-local-backup.sh'

  file { $local_backup_script:
    ensure  => file,
    content => template('hdo/postgresql-local-backup.sh.erb'),
    mode    => '0755',
    require => Class['postgresql::server']
  }

  cron { 'postgresql-local-backup':
    ensure      => $local_backup,
    command     => $local_backup_script,
    user        => 'hdo',
    environment => ['PATH=/usr/local/bin:/usr/bin:/bin', "MAILTO=${hdo::params::admin_email}"],
    minute      => '45'
  }

  #
  # http://blog.gomiso.com/2011/07/28/adventures-in-scaling-part-2-postgresql/
  #
  package { ['ptop', 'pgtune']:
    ensure => installed
  }

}
