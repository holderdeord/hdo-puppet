class elasticsearch::params {
  $package = 'elasticsearch-0.90.5.deb'
  $dependencies = [
    'java7-runtime-headless',
    'java7-runtime'
  ]

  $log_level = 'DEBUG' # default INFO

  if $::virtual == 'virtualbox' {
    $es_heap_size = '128m'
  } else {
    $es_heap_size = '2g'
  }

  if $::hostname in ['hetzner03'] {
    $cluster_name = 'holderdeord-staging'
    $host = '127.0.0.1'
  } else {
    $cluster_name = 'holderdeord'
    $host = '0.0.0.0'
  }

}
