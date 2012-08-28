class hdo::backend {

  include hdo::common

  include apache
  include ruby
  include passenger

  $requirements = [
      'htop',
      'dpkg',
      'build-essential',
      'libxml2',
      'libxml2-dev',
      'libxslt1-dev',
      'git-core',
      'libmysqlclient-dev',
      'libcurl4-openssl-dev',   # libcurl6?
      'imagemagick',
      'vim',
  ]

  $serveradmin = 'teknisk@holderdeord.no'

  package { $requirements:
    ensure => 'installed'
  }

  ruby::gem { 'bundler':
    name => 'bundler'
  }

  file { [ '/webapps', '/webapps/hdo-site', '/webapps/hdo-site/tmp' ]:
    ensure  => 'directory',
    mode    => '0775',
    owner   => 'hdo'
  }

  # work around the apache module's dependency on docroot being present
  # in reality, this is managed by capistrano deployments
  file { '/webapps/hdo-site/current':
    ensure  => link,
    target  => '/webapps/hdo-site/tmp',
    replace => false
  }

  a2mod { 'rewrite':
    ensure => present
  }

  apache::vhost { 'beta.holderdeord.no':
    vhost_name    => '*',
    port          => 80,
    priority      => '20',
    servername    => 'beta.holderdeord.no',
    serveradmin   => $serveradmin,
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
    serveradmin => $serveradmin,
    docroot     => '/webapps/files',
    notify      => Service['httpd'],
  }

}
