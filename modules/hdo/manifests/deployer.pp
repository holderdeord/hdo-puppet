class hdo::deployer {
  include hdo::common
  include passenger::apache

  $appdir  = '/opt/hdo-site'
  $root    = '/webapps/hdo-webhook-deployer'

  $current   = "${root}/current"
  $tmpdir    = "${current}/tmp"
  $shareddir = "${root}/shared"
  $configdir = "${shareddir}/config"
  $logdir    = "${shareddir}/log"

  $token                = hiera('hdo_travis_token', 'default-invalid-token')
  $github_client_id     = hiera('github_client_id', 'default-invalid-id')
  $github_client_secret = hiera('github_client_secret', 'default-invalid-secret')
  $hipchat_api_token    = hiera('hipchat_api_token', '')
  $basic_auth           = hiera('basic_auth')

  ruby::gem { 'hipchat': }

  file { $appdir:
    ensure => directory,
    owner  => $hdo::params::user,
  }

  exec { 'clone-hdo-site':
    command => "git clone git://github.com/holderdeord/hdo-site ${appdir}",
    user    => hdo,
    creates => "${appdir}/config",
    require => File[$appdir]
  }

  exec { 'restart-hdo-webhook-deployer':
    command     => "touch ${tmpdir}/restart.txt",
    user        => hdo,
    refreshonly => true,
  }

  file { [$root, $shareddir, $configdir, $logdir]:
    ensure => directory,
    owner  => hdo
  }

  file { "${configdir}/production.json":
    ensure  => file,
    owner   => hdo,
    mode    => '0644',
    content => template('hdo/deployer.json'),
    notify  => Exec['restart-hdo-webhook-deployer'],
  }

  logrotate::rule { 'hdo-webhook-deployer':
    path         => "${logdir}/*",
    compress     => true,
    copytruncate => true,
    dateext      => true,
    ifempty      => false,
    missingok    => true
  }

  apache::vhost { 'deploy.holderdeord.no':
    vhost_name    => '*',
    port          => 80,
    priority      => '10',
    servername    => 'deploy.holderdeord.no',
    serveradmin   => $hdo::params::admin_email,
    template      => 'hdo/apache-deployer-vhost.conf.erb',
    docroot       => "${current}/public",
    docroot_owner => hdo,
    docroot_group => hdo,
    options       => '-MultiViews -Indexes',
    notify        => Service['httpd'],
    require       => [User['hdo']],
  }

}
