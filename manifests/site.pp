class { 'apt':
  always_apt_update    => true,
  purge_sources_list   => true,
  purge_sources_list_d => true,
}

apt::source { 'puppetlabs':
  location   => 'http://apt.puppetlabs.com',
  repos      => 'main dependencies',
  key        => '4BD6EC30',
  key_server => 'pgp.mit.edu',
}

apt::ppa { 'ppa:vbulax/collectd5': }

#
# Hetzner's default Ubuntu image points at their outdated mirrors, so we add our own sources.list here.
#

apt::source { 'de-archive':
  location   => 'http://de.archive.ubuntu.com/ubuntu/',
  release    => 'precise',
  repos      => 'main restricted universe multiverse',
}

apt::source { 'de-archive-updates':
  location   => 'http://de.archive.ubuntu.com/ubuntu/',
  release    => 'precise-updates',
  repos      => 'main restricted universe multiverse',
}

apt::source { 'de-archive-backports':
  location   => 'http://de.archive.ubuntu.com/ubuntu/',
  release    => 'precise-backports',
  repos      => 'main restricted universe multiverse',
}

apt::source { 'security':
  location   => 'http://security.ubuntu.com/ubuntu',
  release    => 'precise-security',
  repos      => 'main restricted universe multiverse',
}

Exec {
  logoutput => on_failure,
  path => [
    '/usr/bin',
    '/bin',
    '/usr/local/bin'
  ]
}

include hdo::users

import 'nodes.pp'
