class munin::params {
  #munin server package
  $server_package_name = 'munin'

  # TODO: replace with basic auth
  $allow_from  = [
    '10.0.2.2',       # vagrant
    '195.159.164.228' # mesh
  ]
  $docroot     = '/var/cache/munin/www'
  $servername  = 'munin.holderdeord.no'
  $port        = 80
  $serveradmin = 'ops@holderdeord.no'

  #packages on munin node
  $node_package_name   = ['munin-node', 'munin-plugins-extra']
  $common_package_name = 'munin-common'
  $plugin_conf_dir     = '/etc/munin/plugin-conf.d'
}
