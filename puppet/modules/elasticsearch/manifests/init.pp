class elasticsearch {
  #include elasticsearch::config, elasticsearch::install, elasticsearch::service
  include elasticsearch::config, elasticsearch::install

  service { 'elasticsearch':
    ensure => running,
    enable => true, 
    hasstatus => true,
    hasrestart => true,
    path => '/etc/init.d/',
    require => Class['elasticsearch::install', 'elasticsearch::config'],
    #notice("dette er i service typen")
  }
}
