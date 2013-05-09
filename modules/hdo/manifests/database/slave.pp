class hdo::database::slave(
  $master_db_host = undef
){
  include hdo::database::common

  file { '/var/lib/postgresql/9.1/main/recovery.conf':
    ensure  => file,
    owner   => 'postgres',
    content => template('hdo/recovery.conf.erb')
  }
}