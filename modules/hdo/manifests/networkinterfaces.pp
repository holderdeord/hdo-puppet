define hdo::networkinterfaces() {
  file { '/etc/network/interfaces':
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0644',
    source => "puppet:///modules/hdo/etc/network/interfaces.${name}",
    notify => Exec['restart-networking'],
  }

  exec { 'restart-networking':
    command     => 'service networking restart',
    refreshonly => true,
  }

}