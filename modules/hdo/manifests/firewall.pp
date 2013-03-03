define hdo::firewall() {
  $path = "/root/${name}.iptables.sh"

  file { $path:
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0700'
  }

  exec { "firewall '${name}' @ ${::fqdn}": command => $path }
}