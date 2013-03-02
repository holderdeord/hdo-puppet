define varnish::vcl ($source) {
  file { "/etc/varnish/${name}":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => $source,
    require => Package['varnish'],
    notify  => Service['varnish'],
  }
}

