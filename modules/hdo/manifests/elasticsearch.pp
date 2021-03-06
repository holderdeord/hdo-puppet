class hdo::elasticsearch(
  $version            = '2.2.1',
  $cluster_name       = 'holderdeord',
  $number_of_shards   = 5,
  $number_of_replicas = 0,
  $log_level          = 'DEBUG',
) {

  if $::virtual == 'virtualbox' {
    $heap_size = '128m'
  } else {
    $heap_size = '2g'
  }

  $init_defaults = {
    'ES_HEAP_SIZE' => $heap_size
  }

  $config = {
    'cluster.name'             => $cluster_name,
    'index.number_of_shards'   => $number_of_shards,
    'index.number_of_replicas' => $number_of_replicas,
  }

  class { '::elasticsearch':
    package_url           => "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-${version}.deb",
    java_install          => true,
    autoupgrade           => true,
    default_logging_level => $log_level,
    init_defaults         => $init_defaults,
    config                => $config,
  }

  elasticsearch::instance { $::hostname:
    config        => $config,
    init_defaults => $init_defaults,
  }

  file { "/etc/elasticsearch/${::hostname}/hdo.words.nb.txt":
    ensure  => file,
    mode    => '0644',
    source  => 'puppet:///modules/hdo/elasticsearch/hdo.words.nb.txt',
    require => File['/etc/elasticsearch']
  }

  file { "/etc/elasticsearch/${::hostname}/hdo.synonyms.nb.txt":
    ensure  => file,
    mode    => '0644',
    source  => 'puppet:///modules/hdo/elasticsearch/hdo.synonyms.nb.txt',
    require => File['/etc/elasticsearch']
  }

  include nagios::base

  file { "${nagios::base::checks_dir}/elasticsearch":
    ensure => present,
    mode   => '0700',
    owner  => $nagios::base::user,
    group  => $nagios::base::user,
    source => 'puppet:///modules/hdo/nagioschecks/elasticsearch'
  }

  file { "${nagios::base::checks_dir}/elasticsearch-cluster-state":
    ensure => present,
    mode   => '0700',
    owner  => $nagios::base::user,
    group  => $nagios::base::user,
    source => 'puppet:///modules/hdo/nagioschecks/elasticsearch-cluster-state'
  }

  logrotate::rule { 'hdo-elasticsearch':
    path         => "/var/log/elasticsearch/${::hostname}/*",
    compress     => true,
    copytruncate => true,
    dateext      => true,
    ifempty      => false,
    missingok    => true
  }

}