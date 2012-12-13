exec { 'apt-update':
  command => '/usr/bin/apt-get update',
}

Exec { path => '/usr/bin:/bin:/usr/local/bin' }
Exec['apt-update'] -> Package <| |>

exec { 'persist-firewall':
  command     => '/sbin/iptables-save > /etc/iptables.rules',
  refreshonly => true,
}

include hdo::firewall::pre
include hdo::firewall::post

# These defaults ensure that the persistence command is executed after
# every change to the firewall, and that pre & post classes are run in the
# right order to avoid potentially locking you out of your box during the
# first puppet run.
Firewall {
  notify  => Exec['persist-firewall'],
  before  => Class['hdo::firewall::post'],
  require => Class['hdo::firewall::pre'],
}

Firewallchain {
  notify => Exec['persist-firewall'],
}

# This will clear any existing rules, and make sure that only rules
# defined in puppet exist on the machine
resources { 'firewall': purge => true }

import 'nodes.pp'
