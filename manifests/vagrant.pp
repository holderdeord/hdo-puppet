import "site.pp"

# not sure why this is necessary.
group { 'puppet': ensure => present }

#
# For testing, you can add these entries to /etc/hosts:
#
# 192.168.1.10 hdo-ops-vm.holderdeord.no
# 192.168.1.11 hdo-cache-vm.holderdeord.no
# 192.168.1.12 hdo-app-vm.holderdeord.no
# 192.168.1.13 hdo-db-vm.holderdeord.no
# 192.168.1.14 hdo-es-vm.holderdeord.no
#

node 'hdo-ops-vm' {
  include nagios::monitor
}

node 'hdo-cache-vm' {
  include nagios::target

  class { 'varnish':
    backends    => [{ host => "192.168.1.12", port => 80 }] ,
    listen_port => 80
  }
}

node 'hdo-app-vm' {
  include nagios::target

  class { 'hdo::webapp':
    server_name       => 'hdo-app-vm.holderdeord.no',
    db_host           => '192.168.1.13',
    elasticsearch_url => 'http://192.168.1.14:9200',
    ssl               => false,
  }
}

node 'hdo-db-vm' {
  include nagios::target
  class { 'hdo::database::master':
    slave_db_host => '192.168.1.132',
  }
}

node 'hdo-db2-vm' {
  include nagios::target
  class { 'hdo::database::slave':
    master_db_host => '192.168.1.13',
  }

}

node 'hdo-es-vm' {
  include nagios::target
  include elasticsearch
}
