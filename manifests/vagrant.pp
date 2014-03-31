import "site.pp"

# not sure why this is necessary.
group { 'puppet': ensure => present }

#
# For testing, you can add these entries to /etc/hosts:
#
# 192.168.1.10 hdo-ops-vm.holderdeord.no
# 192.168.1.10 hdo-kibana-vm.holderdeord.no
# 192.168.1.10 hdo-graphite-vm.holderdeord.no
# 192.168.1.11 hdo-files-vm.holderdeord.no
#

node 'hdo-ops-vm' {
  # include nagios::monitor
  # include nagios::monitor::front

  include statsd
  include graphite

  include hdo::common
  include kibana
  include grafana

}

node 'hdo-files-vm' {
  include nagios::target

  class { 'hdo::webapp':
    db_host           => 'localhost',
    elasticsearch_url => 'http://localhost:9200'
  }

  class { 'hdo::database':
    local_backup => absent,
  }

  include hdo::files
  include elasticsearch
}
