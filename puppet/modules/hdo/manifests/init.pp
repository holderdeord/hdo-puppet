class hdo {
  include apache
  $passenger_ruby          = "/usr/bin/ruby1.9.1"
  $passenger_root          = "/usr/lib/phusion-passenger"
  $passenger_min_instances = 3
  $passenger_max_pool_size = 10
  $passenger_max_instances_per_app = 10 # only running one app
  $passenger_pool_idle_time = 300

  if $mysql_root_password {} else { $mysql_root_password = "dont-use-this" }
  if $mysql_hdo_password {} else { $mysql_hdo_password = "dont-use-this" }

  package { [
      "python-software-properties",
      "htop",
      "build-essential",
      "libxml2",
      "libxml2-dev",
      "libxslt1-dev",
      "git-core",
      "libmysqlclient-dev"
    ]: ensure  => present
  }

  exec { "brightbox-ruby-experimental":
    path    => ["/bin", "/usr/bin"],
    command => "add-apt-repository ppa:brightbox/ruby-ng-experimental && apt-get update",
    creates => "/etc/apt/sources.list.d/brightbox-ruby-ng-experimental-lucid.list",
    require => Package["python-software-properties"],
  }

  exec { "brightbox-passenger":
    path    => ["/bin", "/usr/bin"],
    command => "add-apt-repository ppa:brightbox/passenger && apt-get update",
    creates => "/etc/apt/sources.list.d/brightbox-passenger-lucid.list",
    require => Package["python-software-properties"],
  }

  package { "libapache2-mod-passenger":
    ensure => present,
    require => Exec['brightbox-passenger']
  }

  package { "passenger-common1.9.1":
    ensure => present,
    require => Exec['brightbox-passenger']
  }

  define gem ($name) {
    exec { "$name-gem":
      command => "gem1.9.3 install $name",
      onlyif  => "gem1.9.3 search -i $name | grep false",
      require => [Package['ruby1.9.3']]
    }
  }

  gem { "bundler": name => bundler}
  gem { "builder": name => builder}
  gem { "nokogiri": name => nokogiri, require => Package['libxml2', 'libxml2-dev', 'libxslt1-dev']}

  package { "ruby":
    ensure  => present,
    require => Exec["brightbox-ruby-experimental"]
  }

  package { "ruby1.9.3":
    ensure  => present,
    require => Exec["brightbox-ruby-experimental"]
  }

  package { "ruby-switch":
    ensure  => present,
    require => Package["ruby1.9.3"]
  }

  exec { "ruby-switch-set":
    command => "/usr/bin/ruby-switch --set ruby1.9.1", # actually 1.9.3..
    require => Package['ruby-switch']
  }

  user { "hdo":
    ensure     => present,
    home       => "/home/hdo",
    managehome => true,
    password   => "7ba6c44a47bd64d32fd2360d70087deaf222d55e",
    shell      => "/bin/bash"
  }

  file { "/home/hdo":
    ensure => directory,
    owner => hdo
  }

  # avoid puppet bug
  group { "puppet":
    ensure => present
  }

  file { "/webapps":
     ensure => directory,
     mode   => 775,
     owner  => hdo
  }

  file { "/code":
     ensure => directory,
     mode   => 775,
     owner  => hdo
  }

  file { "/webapps/files":
    ensure => directory,
    mode   => 775,
    owner  => hdo
  }

  exec { "hdo-storting-importer":
    command => "/usr/bin/git clone https://github.com/holderdeord/hdo-storting-importer /code/hdo-storting-importer",
    creates => "/code/hdo-storting-importer",
    require => [Package['git-core'], File['/code']],
    user    => hdo
  }

  exec { "folketingparser":
    command   => "git submodule update --init",
    require   => Exec['hdo-storting-importer'],
    cwd       => "/code/hdo-storting-importer",
    user      => hdo,
    logoutput => on_failure,
    # gitorious seems flaky:
    tries     => 10,
    try_sleep => 5
  }

  class { 'mysql::server':
    config_hash => { 'root_password' => $mysql_root_password }
  }

  mysql::db { 'hdo_production':
    user     => 'hdo',
    password => $mysql_hdo_password,
    host     => 'localhost',
    grant    => ['all'],
  }

  file { "/home/hdo/.hdo-database.yml":
    owner   => hdo,
    mode    => 600,
    content => template("hdo/database.yml"),
    require => File["/home/hdo"]
  }

  apache::vhost::redirect { "holderdeord.no":
    port          => 80,
    priority      => '10',
    dest          => "http://beta.holderdeord.no",
    serveraliases => 'www.holderdeord.no',
    notify        => Service['apache2']
  }

  apache::vhost { "beta.holderdeord.no":
    vhost_name => "*",
    port       => 80,
    priority   => '20',
    servername => "beta.holderdeord.no",
    template   => "hdo/vhost.conf.erb",
    docroot    => "/webapps/hdo-site/current/public",
    options    => "-MultiViews",
    notify     => Service['apache2']
  }

  apache::vhost { "files.holderdeord.no":
    post     => 80,
    priority => '30',
    docroot  => "/webapps/files",
    notify   => Service['apache2'],
    require  => File['/webapps/files']
  }

  file { "/etc/apache2/conf.d/passenger.conf":
    owner   => root,
    mode    => 644,
    content => template("hdo/passenger.conf.erb"),
    notify  => Service['apache2']
  }

  a2mod { "rewrite": ensure => present }
}

