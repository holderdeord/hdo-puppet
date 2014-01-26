class kibana(
    $root = '/opt/kibana'
  ) {

  include hdo::common
  include apache

  $document_root = "${root}/kibana-latest"
  $credentials   = hiera('basic_auth', 'hdo hdo')
  $htpasswd_path = "${root}/kibana.htpasswd"

  file { $root:
    ensure => directory,
    owner  => hdo,
    group  => hdo,
    mode   => '0755',
  }

  exec { 'download-kibana':
    command => "curl http://download.elasticsearch.org/kibana/kibana/kibana-latest.zip -o ${document_root}.zip",
    creates => "${document_root}.zip",
    user    => hdo,
    require => [File[$root], Package['curl']],
  }

  exec { 'extract-kibana':
    command => "unzip ${document_root}.zip",
    creates => $document_root,
    cwd     => $root,
    user    => hdo,
    require => Exec['download-kibana'],
  }

  file { "${document_root}/config.js":
    ensure  => file,
    owner   => hdo,
    group   => hdo,
    mode    => '0644',
    source  => 'puppet:///modules/kibana/config.js',
    require => Exec['extract-kibana']
  }

  exec { 'create-kibana-htpasswd':
    command   => "htpasswd -b -s -c ${htpasswd_path} ${credentials}",
    creates   => $htpasswd_path,
    require   => Class['apache'],
  }

  a2mod { 'proxy': ensure => present; }
  a2mod { 'proxy_http': ensure => present; }

  apache::vhost { 'kibana.holderdeord.no':
    vhost_name    => '*',
    port          => 80,
    priority      => '20',
    servername    => 'kibana.holderdeord.no',
    serveradmin   => $hdo::params::admin_email,
    template      => 'kibana/apache-kibana-vhost.conf.erb',
    docroot       => $document_root,
    docroot_owner => hdo,
    docroot_group => hdo,
    options       => '-MultiViews -Indexes',
    notify        => Service['httpd'],
    require       => [User['hdo'], A2mod['proxy'], A2mod['proxy_http']],
  }
}