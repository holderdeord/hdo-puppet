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

  package { $requirements:
    ensure => "installed"
  }

  ruby::gem {
    "bundler":
      name => "bundler";
  }

  file { [ "/webapps", "/webapps/files" ]:
    ensure  => "directory",
    mode    => '0775',
    owner   => "hdo",
    require => User["hdo"],
  }

  a2mod { "rewrite": }

  apache::vhost::redirect { "holderdeord.no":
    port          => 80,
    priority      => '10',
    dest          => "http://beta.holderdeord.no",
    serveraliases => 'www.holderdeord.no',
    notify        => Service['httpd']
  }

  apache::vhost { "beta.holderdeord.no":
    vhost_name => "*",
    port       => 80,
    priority   => '20',
    servername => "beta.holderdeord.no",
    template   => "hdo/vhost.conf.erb",
    docroot    => "/webapps/hdo-site/current/public",
    options    => "-MultiViews",
    notify     => Service['httpd']
  }

  apache::vhost { "files.holderdeord.no":
    port     => 80,
    priority => '30',
    docroot  => "/webapps/files",
    notify   => Service['httpd'],
    require  => File['/webapps/files']
  }

}
