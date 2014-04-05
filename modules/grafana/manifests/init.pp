class grafana(
    $root = '/webapps/grafana'
) {

  include hdo::common
  include apache

  $version       = '1.5.2'
  $document_root = "${root}/grafana-${version}"
  $credentials   = hiera('basic_auth', 'hdo hdo')

  file { $root:
    ensure => directory,
    owner  => $hdo::params::user,
    group  => $hdo::params::user,
    mode   => '0755',
  }

  exec { 'download-grafana':
    command => "curl --fail -L https://github.com/torkelo/grafana/releases/download/v${version}/grafana-${version}.zip -o ${document_root}.zip",
    creates => "${document_root}.zip",
    user    => $hdo::params::user,
    require => [File[$root], Package['curl']],
  }

  exec { 'extract-grafana':
    command => "unzip ${document_root}.zip",
    creates => $document_root,
    cwd     => $root,
    user    => $hdo::params::user,
    require => Exec['download-grafana'],
  }

  file { "${document_root}/config.js":
    ensure  => file,
    owner   => $hdo::params::user,
    group   => $hdo::params::user,
    mode    => '0644',
    content => template('grafana/config.js.erb'),
    require => Exec['extract-grafana']
  }

  file { "${root}/latest":
    ensure  => $document_root,
    require => Exec['extract-grafana'],
  }

}
