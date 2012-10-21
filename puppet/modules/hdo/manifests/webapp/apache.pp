class hdo::webapp::apache inherits hdo::webapp {
  include ::apache
  include passenger::apache
  include hdo::params

  a2mod { 'rewrite':
    ensure => present
  }

  apache::vhost { 'beta.holderdeord.no':
    vhost_name    => '*',
    port          => 80,
    priority      => '20',
    servername    => 'beta.holderdeord.no',
    serveradmin   => 'kontakt@holderdeord.no',
    template      => 'hdo/apache-vhost.conf.erb',
    docroot       => $hdo::params::public_dir,
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
    serveradmin => 'kontakt@holderdeord.no',
    docroot     => '/webapps/files',
    notify      => Service['httpd'],
  }

  # work around the apache module's dependency on docroot being present
  # in reality, this is managed by capistrano deployments

  file { "${hdo::params::deploy_root}/tmp":
    ensure  => directory,
    owner   => 'hdo',
    require => [File[$hdo::params::deploy_root]]
  }

  file { $hdo::params::app_root:
    ensure  => link,
    target  => '/webapps/hdo-site/tmp',
    replace => false,
    require => File["${hdo::params::deploy_root}/tmp"]
  }
}
