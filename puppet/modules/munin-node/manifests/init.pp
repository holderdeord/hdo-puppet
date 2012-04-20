class munin-node($master_host) {
  package { "munin-node": ensure => installed, }
  service { 'munin-node': ensure => running, }
  
  file { "/etc/munin/munin-node.conf":
    ensure => file,
    mode => 0644,
    content => template("munin-node/munin-node.conf"),
    notify  => Service['munin-node']
  }
  
}