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

  file { [ "/webapps" ]:
    ensure  => "directory",
    mode    => '0775',
    owner   => "hdo",
    require => User["hdo"],
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
    options     => "-MultiViews",
    notify      => Service['httpd'],
    require     => A2mod['rewrite']
  }

  apache::vhost { "files.holderdeord.no":
    port        => 80,
    priority    => '30',
    docroot     => "/webapps/files",
    serveradmin => $serveradmin,
    notify      => Service['httpd'],
  }

}
