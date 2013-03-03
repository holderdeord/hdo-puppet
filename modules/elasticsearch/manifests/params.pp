class elasticsearch::params {
  $package = 'elasticsearch-0.20.5.deb'
  $dependencies = [
    'java7-runtime-headless',
    'java7-runtime'
  ]

  $host         = '127.0.0.1' # default: 0.0.0.0
  $root_logger  = 'DEBUG, console, file' # default INFO

  case $::hostname {
    'hdo-devel': {
      $es_heap_size = '512m'
    }
    default: {
      $es_heap_size = '2g'
    }
  }
}
