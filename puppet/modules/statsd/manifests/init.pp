class statsd(
  $ensure        = 'running',
  $version       = false,
  $port          = 8125,
  $graphite_host = 'localhost',
  $graphite_port = 2003,
) {

  include nodejs

  nodejs::npm { 'statsd':
    version => $version,
    notify  => Service['statsd'],
  }

  file { '/etc/statsd':
    ensure => directory
  }

  file { '/etc/statsd/config.js':
    ensure  => file,
    mode    => '0644',
    content => template('statsd/config.js.erb'),
    require => File['/etc/statsd'],
    notify  => Service['statsd'],
  }

  file { '/var/log/statsd':
    ensure => directory,
    group  => ['nogroup', 'adm'],
    mode   => '0770',
  }

  logrotate::rule { 'statsd':
    path         => '/var/log/statsd/*',
    compress     => true,
    copytruncate => true,
    dateext      => true,
    ifempty      => false,
    missingok    => true
  }

  file { '/usr/share/statsd':
    ensure => directory,
    group  => 'nogroup',
  }

  file { '/usr/share/statsd/start.sh':
    ensure  => file,
    mode    => '0744',
    owner   => 'nobody',
    group   => 'nogroup',
    content => template('statsd/start.sh'),
    require => File['/usr/share/statsd'],
    notify  => Service['statsd'],
  }

  file { '/etc/init/statsd.conf':
    ensure  => file,
    content => template('statsd/upstart.conf'),
    notify  => Service['statsd'],
  }

  service { 'statsd':
    ensure     => $ensure,
    provider   => 'upstart',
    require    => [File['/etc/init/statsd.conf'], File['/var/log/statsd']]
  }

  # We should use the firewall module for this (which is already a dependency),
  # but it's not yet well supported in Puppet 3:
  #
  # * http://projects.puppetlabs.com/issues/16675
  # * https://github.com/puppetlabs/puppetlabs-firewall/pull/98
  # * https://travis-ci.org/puppetlabs/puppetlabs-firewall
  #
  # If the need arises for more advanced firewalling, we should
  # definitely re-investigate that option.

  exec { 'statsd-firewall':
    logoutput => on_failure,
    command   => "bash -c '
      /sbin/iptables -A INPUT -s 5.9.145.15/32 -p udp -m multiport --ports ${port} -j ACCEPT &&
      /sbin/iptables -A INPUT -s 188.40.124.142/32 -p udp -m multiport --ports ${port} -j ACCEPT &&
      /sbin/iptables -A INPUT -s 10.0.2.2/32 -p udp -m multiport --ports ${port} -j ACCEPT &&
      /sbin/iptables -A INPUT -i lo -p udp -m multiport --ports ${port} -j ACCEPT &&
      /sbin/iptables -A INPUT -p udp -m multiport --ports ${port} -j DROP &&
      /sbin/iptables-save > /etc/iptables.rules'"
  }
}