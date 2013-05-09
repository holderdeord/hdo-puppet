class hdo::database::master(
  $slave_db_host = undef
){
  include hdo::database::common

  postgresql::pg_hba_rule { 'allow slave to connect for streaming replication':
    type        => 'host',
    database    => 'replication',
    user        => 'postgres',
    address     => "${slave_db_host}/32",
    auth_method => 'trust',
  }
}