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
    command     => '/etc/init.d/networking stop && /etc/init.d/networking start',
    refreshonly => true,
  }

}