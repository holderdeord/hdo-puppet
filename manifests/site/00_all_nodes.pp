class { 'apt':
  update => { frequency => 'daily' }
}

apt::source { 'puppetlabs':
  location   => 'http://apt.puppetlabs.com',
  repos      => 'main dependencies',
  key        => { 'server' => 'pgp.mit.edu', 'id' => '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30' }
}

if $lsbdistcodename == 'precise' {
  apt::ppa { 'ppa:vbulax/collectd5': }
}

#
# Hetzner's default Ubuntu image points at their outdated mirrors, so we add our own sources.list here.
#

apt::source { 'de-archive':
  location   => 'http://de.archive.ubuntu.com/ubuntu/',
  release    => $lsbdistcodename,
  repos      => 'main restricted universe multiverse',
}

apt::source { 'de-archive-updates':
  location   => 'http://de.archive.ubuntu.com/ubuntu/',
  release    => "${lsbdistcodename}-updates",
  repos      => 'main restricted universe multiverse',
}

apt::source { 'de-archive-backports':
  location   => 'http://de.archive.ubuntu.com/ubuntu/',
  release    => "${lsbdistcodename}-backports",
  repos      => 'main restricted universe multiverse',
}

apt::source { 'security':
  location   => 'http://security.ubuntu.com/ubuntu',
  release    => "${lsbdistcodename}-security",
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

package { ['build-essential']:
  ensure => installed,
}

class { 'hiera':
  eyaml          => true,
  hiera_yaml     => '/etc/puppet/hiera.yaml',
  eyaml_datadir  => '/opt/hdo-puppet/hiera',
  datadir        => '/opt/hdo-puppet/hiera',
  datadir_manage => false,
  hierarchy      => [ 'secure', '%{hostname}', 'common' ]
}

logrotate::conf { '/etc/logrotate.conf':
  su_user  => root,
  su_group => syslog
}

include hdo::users
include hdo::timezone
include '::ntp'
