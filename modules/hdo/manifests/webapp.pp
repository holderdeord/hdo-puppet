class hdo::webapp {
  include hdo::common
  include hdo::params

  package { [
    'htop',
    'dpkg',
    'libxml2',
    'libxml2-dev',
    'libxslt1-dev',
    'imagemagick',
    'libpq-dev',
  ]:
    ensure => 'installed'
  }

  file {
    [
      $hdo::params::deploy_root,
      $hdo::params::files_root,
      $hdo::params::shared_root,
      $hdo::params::config_root
    ]:
    ensure  => 'directory',
    mode    => '0775',
    owner   => 'hdo'
  }

  file { '/etc/profile.d/hdo-webapp.sh':
    ensure  => file,
    mode    => '0775',
    content => template('hdo/profile.sh')
  }

  file { "${hdo::params::config_root}/database.yml":
    owner   => 'hdo',
    mode    => '0600',
    content => template('hdo/database.yml'),
    require => File[$hdo::params::config_root]
  }

  file { "${hdo::params::config_root}/env.yml":
    owner   => 'hdo',
    mode    => '0600',
    content => template('hdo/env.yml'),
    require => File[$hdo::params::config_root]
  }

  logrotate::rule { 'hdo-site':
    path         => "${hdo::params::shared_root}/log/*.log",
    compress     => true,
    copytruncate => true,
    dateext      => true,
    ifempty      => false,
    missingok    => true
  }
}

