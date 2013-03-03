import "site.pp"

# not sure why this is necessary.
group { 'puppet': ensure => present }

node 'hdo-ops-vm' {
  include nagios::monitor
}

node 'hdo-cache-vm' {
  include nagios::target
}

node 'hdo-app-vm' {
  include nagios::target
}

node 'hdo-db-vm' {
  include nagios::target
}

node 'hdo-es-vm' {
  include nagios::target
}
