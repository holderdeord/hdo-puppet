class hdo::webhooks {
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

  file { $appdir:
    ensure => directory,
    owner  => hdo,
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
    content => template('hdo/webhooks.json'),
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

  apache::vhost { 'hooks.holderdeord.no':
    vhost_name    => '*',
    port          => 80,
    priority      => '10',
    servername    => 'hooks.holderdeord.no',
    serveradmin   => $hdo::params::admin_email,
    template      => 'hdo/apache-webhooks-vhost.conf.erb',
    docroot       => "${current}/public",
    docroot_owner => hdo,
    docroot_group => hdo,
    options       => '-MultiViews -Indexes',
    notify        => Service['httpd'],
    require       => [User['hdo']],
  }

}