class elasticsearch::config inherits elasticsearch::params {
  file { '/etc/default/elasticsearch':
    ensure  => present,
    mode    => '0644',
    content => template('elasticsearch/default.erb')
  }

  file {'/etc/init.d/elasticsearch':
    ensure  => present,
    mode    => '0750',
    content => template('elasticsearch/init.d/elasticsearch.erb')
  }

  file { '/etc/elasticsearch/elasticsearch.yml':
    ensure  => file,
    mode    => '0644',
    content => template('elasticsearch/elasticsearch.yml.erb')
  }

  file { '/etc/elasticsearch/logging.yml':
    ensure  => file,
    mode    => '0644',
    content => template('elasticsearch/logging.yml.erb')
  }
}
