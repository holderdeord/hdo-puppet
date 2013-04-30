#
# Hetzner's default Ubuntu image points at their outdated mirrors, so we add our own sources.list here.
#

file { "/etc/apt/sources.list":
  ensure => file,
  source => "puppet:///modules/hdo/apt/sources.list",
  owner  => root,
  group  => root,
  mode   => '0644',
}

exec { 'apt-update':
  command => '/usr/bin/apt-get update',
  require => File['/etc/apt/sources.list']
}

Exec {
  logoutput => on_failure,
  path => [
    '/usr/bin',
    '/bin',
    '/usr/local/bin'
  ]
}

Exec['apt-update'] -> Package <| |>

include hdo::users

import 'nodes.pp'
