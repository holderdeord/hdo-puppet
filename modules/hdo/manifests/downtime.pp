class hdo::downtime {
  include hdo::common

  $root    = '/webapps/www-downtime'
  $docroot = "${root}/public"

  file { [$root, $docroot]:
    ensure => directory,
    owner  => $hdo::params::user,
  }

  file { "${docroot}/index.html":
    ensure => present,
    source => 'puppet:///modules/hdo/downtime/index.html',
  }

  apache::vhost { 'www.holderdeord.no-downtime':
    vhost_name    => '*',
    port          => 80,
    priority      => '5',
    servername    => 'www.holderdeord.no',
    serveraliases => 'holderdeord.no beta.holderdeord.no',
    serveradmin   => $hdo::params::admin_email,
    docroot       => $docroot,
    docroot_owner => $hdo::params::user,
    docroot_group => $hdo::params::user,
    options       => '-MultiViews -Indexes',
    notify        => Service['httpd'],
    require       => [User['hdo']],
  }

}
