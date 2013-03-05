define hdo::firewall() {
  $path = "/root/${name}.iptables.sh"

  file { $path:
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0700',
    source  => "puppet:///modules/hdo/firewall/${name}.iptables",
  }

  exec { "firewall '${name}' @ ${::fqdn}": command => $path }
}