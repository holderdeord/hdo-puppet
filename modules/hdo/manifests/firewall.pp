define hdo::firewall() {
  $path      =  "/root/${name}.iptables.sh"
  $blacklist = '/root/ip.blocked'

  file { $path:
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0700',
    source => "puppet:///modules/hdo/firewall/${name}.iptables",
  }

  file { $blacklist:
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0644',
    source => 'puppet:///modules/hdo/firewall/ip.blocked'
  }

  exec { "firewall '${name}' @ ${::fqdn}":
    command => $path,
    require => [File[$path], File[$blacklist]]
  }
}
