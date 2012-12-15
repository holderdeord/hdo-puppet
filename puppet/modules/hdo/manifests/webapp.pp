class hdo::webapp {
  include ruby
  include hdo::common
  include hdo::params

  $requirements = [
    'htop',
    'dpkg',
    'git-core',
    'libxml2',
    'libxml2-dev',
    'libxslt1-dev',
    'imagemagick',
  ]

  package { $requirements:
    ensure => 'installed'
  }

  ruby::gem { 'bundler':
    name    => 'bundler',
    version => '>= 1.2.0'
  }

  file { [ $hdo::params::webapp_root, $hdo::params::deploy_root, $hdo::params::files_root ]:
    ensure  => 'directory',
    mode    => '0775',
    owner   => 'hdo'
  }

  file { '/etc/profile.d/hdo-webapp.sh':
    ensure  => file,
    mode    => '0775',
    content => template('hdo/profile.sh')
  }

  file { '/home/hdo/.hdo-database-pg.yml':
    owner   => 'hdo',
    mode    => '0600',
    content => template('hdo/database.yml'),
    require => File['/home/hdo']
  }

  logrotate::rule { 'hdo-site':
    path         => "${hdo::params::deploy_root}/shared/log/*.log",
    compress     => true,
    copytruncate => true,
    dateext      => true,
    ifempty      => false,
    missingok    => true
  }
}

