import "site.pp"

# not sure why this is necessary.
group { 'puppet': ensure => present }

#
# For testing, you can add these entries to /etc/hosts:
#
# 192.168.1.10 hdo-ops-vm.holderdeord.no
# 192.168.1.10 hdo-kibana-vm.holderdeord.no
# 192.168.1.11 hdo-files-vm.holderdeord.no
# 192.168.1.12 hdo-app-vm.holderdeord.no
# 192.168.1.13 hdo-db1-vm.holderdeord.no
# 192.168.1.14 hdo-db2-vm.holderdeord.no
# 192.168.1.15 hdo-es-vm.holderdeord.no
#

node 'hdo-ops-vm' {
  # include nagios::monitor
  # include nagios::monitor::front
  #
  # include hdo::puppetmasterd
  include hdo::common
  include kibana
}

node 'hdo-files-vm' {
  include nagios::target

  class { 'hdo::webapp':
    db_host           => 'localhost',
    elasticsearch_url => 'http://localhost:9200'
  }

  class { 'hdo::database':
    local_backup => present,
  }

  include hdo::files
  include elasticsearch

}

node 'hdo-app-vm' {
  include nagios::target

  class { 'hdo::webapp':
    server_name       => 'hdo-app-vm.holderdeord.no',
    db_host           => '192.168.1.13',
    elasticsearch_url => ['http://192.168.1.15:9200'],
    ssl               => false,
  }
}

node 'hdo-db1-vm' {
  include nagios::target

  class { 'hdo::database':
    standby_ip   => '192.168.1.14',
  }
}

node 'hdo-db2-vm' {
  include nagios::target

  class { 'hdo::database':
    primary_ip => '192.168.1.13',
  }
}

node 'hdo-es1-vm' {
  include nagios::target
  include elasticsearch
}
