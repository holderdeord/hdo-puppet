define munin::plugin($source = false, $plugin_name = $name) {
  $config_path  = '/etc/munin'
  $plugins_path = "${config_path}/plugins"
  $plugin_path  = "${plugins_path}/${name}"

  if ! defined(File[$config_path]) {
    file { $config_path: ensure => directory }
  }

  if ! defined(File[$plugins_path]) {
    file { $plugins_path: ensure => directory }
  }

  if $source != false {
    # custom plugin
    file { $plugin_path:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      source  => $source,
      notify  => Service['munin-node'],
    }
  } else {
    # default plugin
    file { $plugin_path:
      ensure  => symlink,
      replace => false,
      target  => "/usr/share/munin/plugins/${plugin_name}",
      notify  => Service['munin-node'],
    }
  }
}