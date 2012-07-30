class hdo::backend {

  include hdo::common

  include apache
  include ruby
  include passenger

  $requirements = [
      "htop",
      "dpkg",
      "build-essential",
      "libxml2",
      "libxml2-dev",
      "libxslt1-dev",
      "git-core",
      "libmysqlclient-dev",
      "libcurl4-openssl-dev",   # libcurl6?
      "imagemagick",
      "vim",
  ]

  $serveradmin = 'teknisk@holderdeord.no'

  package { $requirements:
    ensure => "installed"
  }

  ruby::gem {
    "bundler":
      name => "bundler";
  }

  file { [ "/webapps", "/webapps/hdo-site" ]:
    ensure  => "directory",
    mode    => '0775',
    owner   => "hdo",
    require => User["hdo"],
  }

  #
  # Work around the fact that the apache module wants to create the
  # docroot for us by creating this dummy symlink which will be
  # updated on deploy.
  #

  file { "/home/hdo/dummy":
    ensure  => directory,
    require => User['hdo']
  }

  file { "/webapps/hdo-site/current":
    ensure  => symlink,
    target  => "/home/hdo/dummy",
    require => File['/home/hdo/dummy']
  }

  a2mod { "rewrite":
    ensure => present
  }

  apache::vhost { "beta.holderdeord.no":
    vhost_name  => "*",
    port        => 80,
    priority    => '20',
    servername  => "beta.holderdeord.no",
    serveradmin => $serveradmin,
    template    => "hdo/vhost.conf.erb",
    docroot     => "/webapps/hdo-site/current/public",
    logroot     => "/var/log/apache2/beta.holderdeord.no",
    options     => "-MultiViews -Indexes",
    notify      => Service['httpd'],
    require     => [A2mod['rewrite'], File["/webapps/hdo-site/current"]]
  }

  apache::vhost { "files.holderdeord.no":
    port        => 80,
    priority    => '30',
    servername  => 'files.holderdeord.no',
    serveradmin => $serveradmin,
    docroot     => "/webapps/files",
    logroot     => "/var/log/apache2/files.holderdeord.no",
    notify      => Service['httpd'],
  }

}
