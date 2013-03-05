import "site.pp"

# not sure why this is necessary.
group { 'puppet': ensure => present }

# 192.168.1.10
node 'hdo-ops-vm' {
  include nagios::monitor
}

# 192.168.1.11
node 'hdo-cache-vm' {
  include nagios::target

  class { 'varnish':
    backends    => [{ host => "192.168.1.12", port => 80 }] ,
    listen_port => 80
  }
}

# 192.168.1.12
node 'hdo-app-vm' {
  include nagios::target

  class { 'hdo::webapp':
    name => 'staging'
  }
}

# 192.168.1.13
node 'hdo-db-vm' {
  include nagios::target

  include hdo::database
}

# 192.168.1.14
node 'hdo-es-vm' {
  include nagios::target
}
