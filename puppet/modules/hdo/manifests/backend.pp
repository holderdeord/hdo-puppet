class hdo::backend {

  include hdo::common
  include ruby
  include hdo::apache

  $requirements = [
      'htop',
      'dpkg',
      'build-essential',
      'libxml2',
      'libxml2-dev',
      'libxslt1-dev',
      'libcurl4-openssl-dev',   # libcurl6?
      'imagemagick',
      'vim',
  ]

  package { $requirements:
    ensure => 'installed'
  }

  ruby::gem { 'bundler':
    name => 'bundler',
    version => '>= 1.2.0'
  }

  file { [ '/webapps', '/webapps/hdo-site', '/webapps/hdo-site/tmp' ]:
    ensure  => 'directory',
    mode    => '0775',
    owner   => 'hdo'
  }

  a2mod { 'rewrite':
    ensure => present
  }

}
