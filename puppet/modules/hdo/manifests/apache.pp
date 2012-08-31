class hdo::apache {
  include apache
  include passenger

  # work around the apache module's dependency on docroot being present
  # in reality, this is managed by capistrano deployments
  file { '/webapps/hdo-site/current':
    ensure  => link,
    target  => '/webapps/hdo-site/tmp',
    replace => false,
    require => File['/webapps/hdo-site']
  }

  apache::vhost { 'beta.holderdeord.no':
    vhost_name    => '*',
    port          => 80,
    priority      => '20',
    servername    => 'beta.holderdeord.no',
    serveradmin   => 'teknisk@holderdeord.no',
    template      => 'hdo/vhost.conf.erb',
    docroot       => '/webapps/hdo-site/current/public',
    docroot_owner => 'hdo',
    docroot_group => 'hdo',
    options       => '-MultiViews -Indexes',
    notify        => Service['httpd'],
    require       => [A2mod['rewrite'], User['hdo']]
  }

  apache::vhost { 'files.holderdeord.no':
    port        => 80,
    priority    => '30',
    servername  => 'files.holderdeord.no',
    serveradmin => 'teknisk@holderdeord.no',
    docroot     => '/webapps/files',
    notify      => Service['httpd'],
  }
}