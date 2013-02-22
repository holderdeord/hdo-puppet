class munin::node(
  $node_package = $munin::params::node_package_name,
) inherits munin::params {

  package { $node_package: }
  Package { ensure => present }

  file { '/etc/munin/munin-node.conf':
    ensure  => present,
    content => template('munin/munin-node.conf'),
    notify  => Service['munin-node'],
  }

  service { 'munin-node':
    ensure => running,
  }

  # default set of plugins
  munin::plugin { 'cpu': }
  munin::plugin { 'df': }
  munin::plugin { 'df_inode': }
  munin::plugin { 'diskstats': }
  munin::plugin { 'entropy': }
  munin::plugin { 'forks': }
  munin::plugin { 'fw_packets': }
  munin::plugin { 'http_loadtime': }
  munin::plugin { 'if_err_eth0': plugin_name => 'if_err_' }
  munin::plugin { 'if_eth0':     plugin_name => 'if_' }
  munin::plugin { 'interrupts': }
  munin::plugin { 'iostat': }
  munin::plugin { 'iostat_ios': }
  munin::plugin { 'irqstats': }
  munin::plugin { 'load': }
  munin::plugin { 'memory': }
  munin::plugin { 'munin_stats': }
  munin::plugin { 'open_files': }
  munin::plugin { 'open_inodes': }
  munin::plugin { 'processes': }
  munin::plugin { 'proc_pri': }
  munin::plugin { 'swap': }
  munin::plugin { 'threads': }
  munin::plugin { 'uptime': }
  munin::plugin { 'vmstat': }
}
