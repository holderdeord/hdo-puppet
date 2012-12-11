exec { 'apt-update':
  command => '/usr/bin/apt-get update',
}

Exec { path => '/usr/bin:/bin' }
Exec['apt-update'] -> Package <| |>


import 'nodes.pp'
