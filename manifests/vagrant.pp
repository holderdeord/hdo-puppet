import "site.pp"

# not sure why this is necessary.
group { 'puppet': ensure => present }

#
# For testing, you can add these entries to /etc/hosts:
#
# 192.168.1.10 hdo-ops-vm.holderdeord.no
# 192.168.1.10 hdo-kibana-vm.holderdeord.no
# 192.168.1.10 hdo-graphite-vm.holderdeord.no
# 192.168.1.11 hdo-app-vm.holderdeord.no
#

node 'hdo-ops-vm' {
  # include nagios::monitor
  # include nagios::monitor::front

  include statsd
  include graphite

  include hdo::common
  include kibana
  include grafana

  class { 'hdo::collectd':
    graphite => 'localhost'
  }
}

node 'hdo-app-vm' {
  # include nagios::target

  class { 'hdo::collectd':
    graphite => '192.168.1.10'
  }

  class { 'hdo::webapp':
    db_host           => 'localhost',
    elasticsearch_url => 'http://localhost:9200'
  }

  class { 'hdo::database':
    local_backup => absent,
    collectd     => true,
  }

  include hdo::files

  class { 'hdo::elasticsearch':
    cluster_name => 'holderdeord-staging'
  }
}
