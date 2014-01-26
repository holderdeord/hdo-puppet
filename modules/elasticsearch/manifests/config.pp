class elasticsearch::config inherits elasticsearch::params {
  file { '/etc/default/elasticsearch':
    ensure  => present,
    mode    => '0644',
    content => template('elasticsearch/default.erb'),
    require => Class['elasticsearch::install'],
  }

  file {'/etc/init.d/elasticsearch':
    ensure  => present,
    mode    => '0750',
    content => template('elasticsearch/init.d/elasticsearch.erb'),
    require => Class['elasticsearch::install'],
  }

  file { '/etc/elasticsearch/elasticsearch.yml':
    ensure  => file,
    mode    => '0644',
    content => template('elasticsearch/elasticsearch.yml.erb'),
    require => Class['elasticsearch::install'],
  }

  file { '/etc/elasticsearch/logging.yml':
    ensure  => file,
    mode    => '0644',
    content => template('elasticsearch/logging.yml.erb'),
    require => Class['elasticsearch::install'],
  }

  file { '/etc/elasticsearch/hdo.words.nb.txt':
    ensure  => file,
    mode    => '0644',
    source  => 'puppet:///modules/elasticsearch/config/hdo.words.nb.txt',
    require => Class['elasticsearch::install'],
  }

  file { '/etc/elasticsearch/hdo.synonyms.nb.txt':
    ensure  => file,
    mode    => '0644',
    source  => 'puppet:///modules/elasticsearch/config/hdo.synonyms.nb.txt',
    require => Class['elasticsearch::install'],
  }


  include nagios::base

  file { "${nagios::base::checks_dir}/elasticsearch":
    ensure => present,
    mode   => '0700',
    owner  => $nagios::base::user,
    group  => $nagios::base::user,
    source => 'puppet:///modules/elasticsearch/nagioschecks/elasticsearch'
  }

  # TODO: parameterize elasticsearch
  if $::hostname != 'hetzner03' {
    file { "${nagios::base::checks_dir}/elasticsearch-cluster-state":
      ensure => present,
      mode   => '0700',
      owner  => $nagios::base::user,
      group  => $nagios::base::user,
      source => 'puppet:///modules/elasticsearch/nagioschecks/elasticsearch-cluster-state'
    }
  }
}
