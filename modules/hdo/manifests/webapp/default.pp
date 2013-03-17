class hdo::webapp::default {
  class { 'hdo::webapp':
    db_host           => '46.4.88.199',
    elasticsearch_url => 'http://46.4.88.197:9200'
  }
}