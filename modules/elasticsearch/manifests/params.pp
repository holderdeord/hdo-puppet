class elasticsearch::params {
  $package = 'elasticsearch-0.20.5.deb'
  $dependencies = [
    'java7-runtime-headless',
    'java7-runtime'
  ]

  $root_logger  = 'DEBUG, console, file' # default INFO

  if $::virtual == 'virtualbox' {
    $es_heap_size = '128m'
    $host = '0.0.0.0'
  } else {
    $host = '127.0.0.1' # default: 0.0.0.0
  }
}
