class munin::params {
  #munin server package
  $server_package_name = 'munin'

  #apache settings
  $allow_from  = ['10.0.2.2']
  $docroot     = '/var/cache/munin/www'
  $servername  = 'munin.holderdeord.no'
  $port        = 80
  $serveradmin = 'ops@holderdeord.no'

  #packages on munin node
  $node_package_name = ['munin-node', 'munin-plugins-extra']
  $common_package_name = 'munin-common'

  #Enabled plugins
  $plugins = ['apache_accesses',
              'apache_volume',
              'cpu',
              'df',
              'df_inode',
              'diskstats',
              'entropy',
              'forks',
              'fw_packets',
              'http_loadtime',
              'if_err_eth0',
              'if_eth0',
              'interrupts',
              'iostat',
              'iostat_ios',
              'irqstats',
              'load',
              'memory',
              'munin_stats',
              'open_files',
              'open_inodes',
              'processes',
              'proc_pri',
              'swap',
              'threads',
              'uptime',
              'vmstat']
}
