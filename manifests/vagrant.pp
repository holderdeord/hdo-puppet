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
  include hdo::users::admins
  include hdo::nodejs

  class { 'hdo::elasticsearch': }

  class { 'passenger::nginx':
    port     => 80,
    nagios   => false,
    munin    => false,
    collectd => false,
    purge    => true
  }

  class { 'hdo::transcripts':
    server_name => 'tale.holderdeord.no'
  }

  class { 'hdo::database':
    munin        => false,
    collectd     => false,
  }

  class { 'hdo::webapp':
    server_name       => 'app.holderdeord.no',
    db_host           => 'localhost',
    elasticsearch_url => 'http://localhost:9200',
  }

}
