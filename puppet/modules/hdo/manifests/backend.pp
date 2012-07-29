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
    "builder":
      name => "builder";
    "nokogiri":
      name => "nokogiri",
      require => Package['libxml2', 'libxml2-dev', 'libxslt1-dev'];
  }

  file { [ "/webapps", "/webapps/files", "/code" ]:
     ensure => "directory",
     mode   => 0775,
     owner  => "hdo",
     require => User["hdo"],
  }

  exec { "hdo-storting-importer":
    command => "/usr/bin/git clone https://github.com/holderdeord/hdo-storting-importer /code/hdo-storting-importer",
    creates => "/code/hdo-storting-importer",
    require => [ Package['git-core'], File['/code'] ],
    user    => "hdo",
  }

  exec { "folketingparser":
    command   => "git submodule update --init",
    require   => Exec['hdo-storting-importer'],
    cwd       => "/code/hdo-storting-importer",
    user      => hdo,
    logoutput => on_failure,
    # gitorious seems flaky:
    tries     => 10,
    try_sleep => 5,
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
