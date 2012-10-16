class elasticsearch::config inherits elasticsearch::params {

  file {'/etc/init.d/elasticsearch':
    ensure  => present,
    mode    => '0750',
    content => template('elasticsearch/init.d/elasticsearch.erb')
  }
}
