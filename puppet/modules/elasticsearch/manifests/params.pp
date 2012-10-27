class elasticsearch::params {
  $package = 'elasticsearch-0.19.9.deb'
  $dependencies = [
    'java7-runtime-headless',
    'java7-runtime',
    'wnorwegian' # for word list
  ]
}
