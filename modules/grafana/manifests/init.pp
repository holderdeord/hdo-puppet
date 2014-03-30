class grafana(
    $root = '/webapps/grafana'
  ) {

  include hdo::common
  include apache

  $version       = '1.5.2'
  $document_root = "${root}/grafana-${version}"
  $credentials   = hiera('basic_auth', 'hdo hdo')
  $htpasswd_path = "${root}/grafana.htpasswd"


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
    require => Exec['extract-kibana']
  }

  exec { 'create-grafana-htpasswd':
    command   => "htpasswd -b -s -c ${htpasswd_path} ${credentials}",
    creates   => $htpasswd_path,
    require   => Class['apache'],
  }

  if !defined(A2mod['proxy']) {
    a2mod { 'proxy': ensure => present; }
  }

  if !defined(A2mod['proxy_http']) {
    a2mod { 'proxy_http': ensure => present; }
  }

  apache::vhost { 'grafana.holderdeord.no':
    vhost_name    => '*',
    port          => 80,
    priority      => '20',
    servername    => 'grafana.holderdeord.no',
    serveradmin   => $hdo::params::admin_email,
    template      => 'grafana/apache-grafana-vhost.conf.erb',
    docroot       => $document_root,
    docroot_owner => $hdo::params::user,
    docroot_group => $hdo::params::user,
    options       => '-MultiViews -Indexes',
    notify        => Service['httpd'],
    require       => [User['hdo'], A2mod['proxy'], A2mod['proxy_http']],
  }
}
