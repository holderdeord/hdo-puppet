class elasticsearch::service {

  service { 'elasticsearch':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Class['elasticsearch::install', 'elasticsearch::config'],
    subscribe  => Class['elasticsearch::config']
  }
}
